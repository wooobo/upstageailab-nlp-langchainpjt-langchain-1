#!/usr/bin/env python3

import os
from dotenv import load_dotenv
from modules.update_pipeline import ingest_all_documents

def main():
    # .env 불러오기
    load_dotenv(dotenv_path='config.env')

    # 문서 ingestion 테스트
    contents = ingest_all_documents()
    print("[Ingestion Test] Fetched contents:")
    for c in contents:
        print("Title:", c["title"])
        print("URL:", c["url"])
        print("Type:", c["type"])
        print("Text snippet:", c["text"][:30], "...")
        print("Images:", c.get("images", []))
        print("-" * 40)

    print("Ingestion complete. (Stub data)")

if __name__ == "__main__":
    main()
