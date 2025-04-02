#!/usr/bin/env python3

"""
Hour 7: 통합 테스트 & 디버깅
- 이 스크립트는 간단한 end-to-end(ingestion -> embedding -> RAG) 테스트를 수행합니다.
- 실제 개발 환경에서는 pytest나 unittest를 사용해 더 체계적으로 작성할 수 있습니다.
"""

import os
import time
from dotenv import load_dotenv

# 모듈 import
from modules.vectorstore import LocalFaissStore
from modules.update_pipeline import update_documents_if_needed, save_last_update_time
from modules.rag import answer_query

def main():
    # 1) .env 로딩
    load_dotenv(dotenv_path='config.env')
    print("[Test] Loaded .env settings.")

    # 2) FAISS Store 생성
    store = LocalFaissStore(dimension=768)
    print("[Test] Created empty LocalFaissStore.")

    # 3) 강제로 update (ingestion + embedding) 수행
    #    .last_update_time을 0으로 설정해 '항상 업데이트'가 되도록 함
    print("[Test] Forcing update by setting last_update_time=0...")
    save_last_update_time(0.0)

    store, updated = update_documents_if_needed(store=store)
    if updated:
        print("[Test] Documents ingestion & embedding done.")
    else:
        print("[Test] No update needed? (Should not happen if we forced it to 0)")

    # 4) RAG 질의 테스트
    test_query = "휴가신청 프로세스 알려줘"
    print(f"[Test] Running RAG query: '{test_query}'")
    result = answer_query(test_query, store, history=None, top_k=3)

    print("[Test] RAG result:")
    print(" - Answer:", result["answer"])
    print(" - Sources:")
    for s in result["sources"]:
        print(f"    * title={s['title']}, url={s['url']}, dist={s['distance']:.2f}")

    # 5) 간단 검증
    # GPT_ANSWER_STUB이 포함되면 '스텁 응답'이 잘 왔다고 간주
    if "GPT_ANSWER_STUB" in result["answer"]:
        print("[Test] OK: GPT Stub answer detected. RAG pipeline seems working in stub mode.")
    else:
        print("[Test] WARNING: GPT answer stub not found. Check call_gpt() logic?")

    print("\n=== End-to-end test complete ===")
    print("If any errors occurred above, please check traceback for debugging.")

if __name__ == "__main__":
    main()
