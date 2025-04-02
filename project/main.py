#!/usr/bin/env python3

import os
from dotenv import load_dotenv

from modules.vectorstore import LocalFaissStore
from modules.update_pipeline import update_documents_if_needed

def main():
    load_dotenv(dotenv_path='config.env')

    # 1) 스토어 생성 (처음에는 빈 상태)
    store = LocalFaissStore(dimension=768)

    # 2) update_documents_if_needed -> .env의 UPDATE_INTERVAL_HOURS 지난 경우 업데이트
    store, updated = update_documents_if_needed(store=store)

    if updated:
        print("[Main] Documents were updated. Now FAISS store is fresh.")
    else:
        print("[Main] No update needed. FAISS store is unchanged.")

    # 이후 RAG 질의응답 로직을 연결하거나,
    # 테스트 검색을 시도하는 코드를 작성 가능.

    # 예: 간단히 검색 테스트 (원하는 경우 주석 해제)
    # query = "휴가 신청 방법"
    # from modules.embedding import embed_chunks
    # query_emb = embed_chunks([query])[0]
    # results = store.search(query_emb, top_k=3)
    # print("[Search Results]")
    # for dist, meta in results:
    #     print(f" - dist={dist:.3f}, title={meta.get('title')}, snippet={meta.get('text_snippet')}")

if __name__ == "__main__":
    main()
