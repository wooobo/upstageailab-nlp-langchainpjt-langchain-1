import os
import requests
import json

from .embedding import embed_chunks

"""
Hour 5 + Hour 8: RAG + GPT 호출 + 예외처리
 - call_gpt(context, api_key, model, temperature, max_tokens): GPT API + 에러 핸들링
 - answer_query(query, store, history): RAG 파이프라인
"""

def call_gpt(context, api_key, model="gpt-4", temperature=0.7, max_tokens=1000):
    """
    실제 GPT-4 또는 사내 GPT 호환 API 호출 예시
    예외처리:
      - HTTP 에러, Timeout 등 발생 시 에러 메시지 반환
    """
    # Stub 모드면 그냥 샘플 메시지
    if api_key == "DUMMY_KEY":
        return f"[GPT_ANSWER_STUB] based on context: {context[:60]}..."

    endpoint = "https://api.openai.com/v1/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }
    data = {
        "model": model,
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": context}
        ],
        "temperature": temperature,
        "max_tokens": max_tokens,
    }
    try:
        response = requests.post(endpoint, headers=headers, data=json.dumps(data), timeout=15)
        response.raise_for_status()  # HTTP 에러 시 예외 발생
        resp_json = response.json()
        return resp_json["choices"][0]["message"]["content"]
    except Exception as e:
        err_msg = f"[Error] GPT API call failed: {type(e).__name__}, {e}"
        print(err_msg)
        return err_msg

def answer_query(query, store, history=None, top_k=3):
    """
    RAG 파이프라인 + 예외처리
    :param query: 사용자 질의
    :param store: LocalFaissStore
    :param history: 이전 대화 히스토리
    :param top_k: 검색할 상위 k개 chunk
    :return: { "answer": "...", "sources": [...] }
    """
    if not query or store is None:
        return {
            "answer": "[Error] Invalid query or store is None",
            "sources": []
        }

    if history is None:
        history = []

    # 1) query 임베딩
    query_embedding = embed_chunks([query])[0]
    if query_embedding is None:
        return {
            "answer": "[Error] Failed to create query embedding",
            "sources": []
        }

    # 2) store.search(query_embedding, top_k)
    results = store.search(query_embedding, top_k=top_k)
    if not results:
        # 검색 결과 없으면
        return {
            "answer": "죄송하지만 해당 질문에 대해 적절한 답변을 찾지 못했습니다.",
            "sources": []
        }

    # 3) chunk context
    context_texts = []
    sources = []
    for dist, meta in results:
        snippet = meta.get('text_snippet', '')
        title = meta.get('title', 'Untitled')
        url = meta.get('url', '')
        chunk_idx = meta.get('chunk_index', 0)

        context_texts.append(f"[{title}#{chunk_idx}] {snippet}")
        sources.append({
            "title": title,
            "url": url,
            "distance": dist
        })

    combined_context = "\n".join(context_texts)

    # 4) GPT 호출
    api_key = os.getenv("OPENAI_API_KEY", "DUMMY_KEY")
    model = os.getenv("GPT_MODEL", "gpt-4")
    temperature = float(os.getenv("TEMPERATURE", "0.7"))
    max_tokens = int(os.getenv("MAX_TOKENS", "1000"))

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
