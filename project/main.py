#!/usr/bin/env python3

import os
from dotenv import load_dotenv

from modules.vectorstore import LocalFaissStore
from modules.update_pipeline import update_documents_if_needed
from modules.rag import answer_query

def main():
    # .env 로드
    load_dotenv(dotenv_path='config.env')

    # 1) 스토어 생성
    store = LocalFaissStore(dimension=768)

    # 2) 문서 자동 업데이트(ingestion + embedding) 확인
    store, updated = update_documents_if_needed(store=store)
    if updated:
        print("[Main] Documents were updated & embedded.")
    else:
        print("[Main] No update needed.")

    # 3) RAG 질의응답 테스트
    test_query = "휴가 신청 프로세스 알려줘"
    rag_result = answer_query(test_query, store=store, history=None, top_k=3)
    print("\n[RAG Test] Query:", test_query)
    print("Answer:", rag_result["answer"])
    print("Sources:")
    for src in rag_result["sources"]:
        print(f" - Title={src['title']}, URL={src['url']}, distance={src['distance']:.2f}")

if __name__ == "__main__":
    main()
