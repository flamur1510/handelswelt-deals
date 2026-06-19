import hashlib
import json
import os
import sys
import time

import requests
from google.oauth2 import service_account

PROJECT_ID = "handelswelt-703b0"
SITE_ID = "handelswelt-deals"
PUBLIC_DIR = os.path.join(os.path.dirname(__file__), "public")
KEY_FILE = os.environ.get(
    "GOOGLE_APPLICATION_CREDENTIALS",
    os.path.expanduser("~/Downloads/handelswelt-703b0-7d36107f1418.json"),
)

SCOPES = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/firebase",
]

API = "https://firebasehosting.googleapis.com/v1beta1"


def get_token():
    creds = service_account.Credentials.from_service_account_file(KEY_FILE, scopes=SCOPES)
    creds.refresh(__import__("google.auth.transport.requests", fromlist=["Request"]).Request())
    return creds.token


def gzip_hash(path):
    import gzip as gziplib
    import io

    with open(path, "rb") as f:
        raw = f.read()
    buf = io.BytesIO()
    with gziplib.GzipFile(fileobj=buf, mode="wb", mtime=0) as gz:
        gz.write(raw)
    compressed = buf.getvalue()
    return hashlib.sha256(compressed).hexdigest(), compressed


def main():
    token = get_token()
    headers = {"Authorization": f"Bearer {token}"}

    files = {}
    for root, _, names in os.walk(PUBLIC_DIR):
        for name in names:
            full = os.path.join(root, name)
            rel = "/" + os.path.relpath(full, PUBLIC_DIR)
            h, data = gzip_hash(full)
            files[rel] = (h, data)

    config = {
        "cleanUrls": True,
        "rewrites": [
            {"glob": "/datenschutz", "path": "/datenschutz.html"},
            {"glob": "/impressum", "path": "/impressum.html"},
        ],
    }

    version_resp = requests.post(
        f"{API}/sites/{SITE_ID}/versions",
        headers=headers,
        json={"config": config},
    )
    version_resp.raise_for_status()
    version_name = version_resp.json()["name"]
    print("Created version:", version_name)

    populate_resp = requests.post(
        f"{API}/{version_name}:populateFiles",
        headers=headers,
        json={"files": {rel: h for rel, (h, _) in files.items()}},
    )
    populate_resp.raise_for_status()
    populate_data = populate_resp.json()
    upload_url = populate_data["uploadUrl"]
    upload_required = set(populate_data.get("uploadRequiredHashes", []))
    print("Files to upload:", len(upload_required))

    for rel, (h, compressed) in files.items():
        if h not in upload_required:
            continue
        resp = requests.post(
            f"{upload_url}/{h}",
            headers={**headers, "Content-Type": "application/octet-stream"},
            data=compressed,
        )
        if resp.status_code != 200:
            print("Upload failed for", rel, resp.status_code, resp.text)
            sys.exit(1)
        print("Uploaded", rel)

    finalize_resp = requests.patch(
        f"{API}/{version_name}?update_mask=status",
        headers=headers,
        json={"status": "FINALIZED"},
    )
    finalize_resp.raise_for_status()
    print("Finalized version")

    release_resp = requests.post(
        f"{API}/sites/{SITE_ID}/releases",
        headers=headers,
        params={"versionName": version_name},
        json={},
    )
    release_resp.raise_for_status()
    print("Released!")
    print(json.dumps(release_resp.json(), indent=2))


if __name__ == "__main__":
    main()
