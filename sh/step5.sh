#!/usr/bin/env bash
#
# step5.sh: Hour 5 - RAG 파이프라인(GPT 호출) 구현
# - Creates/updates rag.py with answer_query() function
# - Updates main.py to demonstrate a basic RAG flow
#

echo "=== Start: Hour 5 - RAG Pipeline & GPT ==="

#############################################
# 1. rag.py 생성/덮어쓰기
#############################################
echo "Updating rag.py..."
cat <<'PYTHON' > project/modules/rag.py
import os
import requests
import json

from .embedding import embed_chunks

"""
Hour 5: RAG + GPT 호출
 - call_gpt(context, api_key, model, temperature, max_tokens): GPT API 스텁
 - answer_query(query, store, history): RAG 파이프라인
   1) 쿼리 임베딩
   2) store.search -> top_k chunk
   3) GPT 호출 (context에 chunk 내용 포함)
   4) 답변 + 출처 반환
"""

def call_gpt(context, api_key, model="gpt-4", temperature=0.7, max_tokens=1000):
    """
    [STUB] 실제 GPT-4 또는 사내 GPT 호환 API 호출 예시
    - OpenAI API 형식을 간단히 이용 (chat/completions)
    - 사내 API라면 endpoint/파라미터 수정 필요
    """
    # 실제 OpenAI API 호출 예시 (Python requests):
    # endpoint = "https://api.openai.com/v1/chat/completions"
    # headers = {
    #     "Content-Type": "application/json",
    #     "Authorization": f"Bearer {api_key}",
    # }
    # data = {
    #     "model": model,
    #     "messages": [
    #         {"role": "system", "content": "You are a helpful assistant."},
    #         {"role": "user", "content": context}
    #     ],
    #     "temperature": temperature,
    #     "max_tokens": max_tokens,
    # }
    # response = requests.post(endpoint, headers=headers, data=json.dumps(data))
    # if response.status_code == 200:
    #     resp_json = response.json()
    #     return resp_json["choices"][0]["message"]["content"]
    # else:
    #     return f"GPT API Error: {response.status_code}, {response.text}"

    # 여기서는 스텁으로 응답
    stub_answer = f"[GPT_ANSWER_STUB] based on context: {context[:60]}..."
    return stub_answer

def answer_query(query, store, history=None, top_k=3):
    """
    RAG 파이프라인
    :param query: 사용자 질의 (str)
    :param store: LocalFaissStore 인스턴스
    :param history: (Optional) 이전 대화 히스토리, ex) [(user, assistant), ...]
    :param top_k: 검색할 상위 k개 chunk
    :return: { "answer": "...", "sources": [ ... ] }
    """
    if history is None:
        history = []

    # 1) query 임베딩
    query_embedding = embed_chunks([query])[0]  # 간단히 1문장
    # 2) store.search(query_embedding, top_k)
    results = store.search(query_embedding, top_k=top_k)

    # 3) 검색된 chunk를 context에 넣기
    context_texts = []
    sources = []
    for dist, meta in results:
        snippet = meta.get('text_snippet', '')
        title = meta.get('title', 'Untitled')
        url = meta.get('url', '')
        chunk_idx = meta.get('chunk_index', 0)

        # context_texts에 snippet 추가
        context_texts.append(f"[{title}#{chunk_idx}] {snippet}")
        # sources 목록
        sources.append({
            "title": title,
            "url": url,
            "distance": dist
        })

    combined_context = "\n".join(context_texts)
    # 예: "User Query: {query}\nRelevant Chunks:\n{combined_context}"

    # 4) GPT 호출
    api_key = os.getenv("OPENAI_API_KEY", "DUMMY_KEY")
    model = os.getenv("GPT_MODEL", "gpt-4")
    temperature = float(os.getenv("TEMPERATURE", "0.7"))
    max_tokens = int(os.getenv("MAX_TOKENS", "1000"))

    # 여기서는 "User Query + 문서 context"를 하나의 prompt로
    prompt = f"User query: {query}\n\nContext:\n{combined_context}\n\nProvide a helpful answer referencing the content above."
    gpt_answer = call_gpt(
        context=prompt,
        api_key=api_key,
        model=model,
        temperature=temperature,
        max_tokens=max_tokens
    )

    return {
        "answer": gpt_answer,
        "sources": sources
    }
PYTHON

#############################################
# 2. main.py 수정 -> RAG 시연
#############################################
echo "Updating main.py..."
cat <<'PYTHON' > project/main.py
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
PYTHON

echo "=== Done (Hour 5) ==="
echo "Now run:"
echo "  cd project"
echo "  source ../.venv/bin/activate"
echo "  python main.py"
echo "You should see a RAG-based answer stub and source references for the query."
