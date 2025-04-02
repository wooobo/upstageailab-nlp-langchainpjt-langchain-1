#!/usr/bin/env bash
#
# step3.sh: Hour 3 - Chunking & 임베딩 구현 스크립트
# - embedding.py (chunk_text, embed_chunks 스텁)
# - vectorstore.py (FAISS store 스텁)
# - main.py (임베딩 테스트 코드 추가)
#

echo "=== Start: Updating chunking & embedding (Hour 3) ==="

#############################################
# 1. embedding.py 생성/덮어쓰기
#############################################
echo "Updating embedding.py..."
cat <<'PYTHON' > project/modules/embedding.py
import os
import math
import requests

"""
 Hour 3: Chunking & 임베딩 구현 (스텁 버전)
 - chunk_text: 문자열을 일정 길이로 분할
 - embed_chunks: 임베딩 API 호출 (OpenAI 호환 스텁)
"""

def chunk_text(full_text: str, chunk_size: int = 512, overlap: int = 0):
    """
    간단히 '문자 단위'로 chunk_size씩 나누는 스텁 함수.
    실제 프로젝트에서는 토큰 단위 분할 또는 문단 단위 분할을 권장.
    :param full_text: 전체 텍스트
    :param chunk_size: chunk 분할 크기
    :param overlap: chunk 간격 겹치는 길이 (필요 시)
    :return: chunk 문자열 리스트
    """
    chunks = []
    idx = 0
    n = len(full_text)

    while idx < n:
        end_idx = idx + chunk_size
        chunk = full_text[idx:end_idx]
        chunks.append(chunk)

        # 오버랩이 있다면, idx를 (end_idx - overlap)로 이동
        idx = end_idx - overlap if overlap > 0 else end_idx

    return chunks

def embed_chunks(chunks, api_key="DUMMY_KEY", model="text-embedding-ada-002"):
    """
    [STUB] 실제로는 OpenAI / 사내 임베딩 API 등을 호출.
    여기서는 간단히 더미 벡터(숫자 리스트)로 대체.
    :param chunks: 텍스트 chunk 리스트
    :param api_key: API 키 (실제 호출 시 필요)
    :param model: 임베딩 모델명
    :return: [ [dim1, dim2, ...], [dim1, dim2, ...], ... ]
    """
    # 예시: 각 chunk마다 길이를 기반으로 한 더미 임베딩
    # 실제로는 requests.post(...) 로 API 호출 후 결과 파싱
    embeddings = []
    for chunk in chunks:
        vec_length = 768  # 예시로 768차원
        dummy_val = len(chunk) % 10  # chunk 길이에 따른 임의 값
        vector = [float(dummy_val) for _ in range(vec_length)]
        embeddings.append(vector)

    return embeddings

PYTHON

#############################################
# 2. vectorstore.py 생성/덮어쓰기
#############################################
echo "Updating vectorstore.py..."
cat <<'PYTHON' > project/modules/vectorstore.py
import faiss
import numpy as np

"""
Hour 3: FAISS VectorStore 스텁
 - LocalFaissStore 클래스
   - add_documents(docs): FAISS 인덱스에 추가
   - search(query_vec, top_k): 유사도 검색
"""

class LocalFaissStore:
    def __init__(self, dimension=768):
        self.dimension = dimension
        # IDMap + Flat Index (간단히 사용)
        self.index = faiss.IndexIDMap(faiss.IndexFlatL2(self.dimension))
        self.id_counter = 0
        self.metadata = {}  # id -> {"text":..., "title":..., "url":...}

    def add_documents(self, embeddings, doc_info_list):
        """
        :param embeddings: List[List[float]]; 임베딩 결과
        :param doc_info_list: List[dict]; 각 embedding의 메타데이터
        """
        vectors = np.array(embeddings).astype('float32')
        n = len(embeddings)
        ids = np.array([self._get_next_id() for _ in range(n)])
        self.index.add_with_ids(vectors, ids)

        # 메타데이터 저장
        for i, doc_info in enumerate(doc_info_list):
            self.metadata[ids[i]] = doc_info

    def search(self, query_embedding, top_k=3):
        """
        :param query_embedding: List[float] shape=(dimension,)
        :param top_k: 상위 k개 결과
        :return: [(score, metadata), ...] 점수 오름차순
        """
        query_vec = np.array([query_embedding], dtype='float32')
        distances, indices = self.index.search(query_vec, top_k)

        results = []
        for dist, idx in zip(distances[0], indices[0]):
            if idx == -1:
                continue
            meta = self.metadata.get(idx, {})
            # L2 distance -> 점수 계산(예: 유사도 = 1 / (1+dist))
            # 일단 dist 자체를 score로 남김
            results.append((dist, meta))
        return results

    def _get_next_id(self):
        current = self.id_counter
        self.id_counter += 1
        return current
PYTHON

#############################################
# 3. main.py 수정하여 Chunking & Embedding 테스트
#############################################
echo "Updating main.py..."
cat <<'PYTHON' > project/main.py
#!/usr/bin/env python3

import os
from dotenv import load_dotenv

from modules.update_pipeline import ingest_all_documents
from modules.embedding import chunk_text, embed_chunks
from modules.vectorstore import LocalFaissStore

def main():
    # 1) .env 로딩
    load_dotenv(dotenv_path='config.env')

    # 2) 문서 인제스션 (스텁)
    contents = ingest_all_documents()
    print("[Ingestion] Document count:", len(contents))

    # 3) Chunking + Embedding + FAISS 저장
    store = LocalFaissStore(dimension=768)

    all_embeddings = []
    all_metadatas = []
    chunk_size = 512
    overlap = 0

    for doc in contents:
        text = doc.get("text", "")
        doc_title = doc.get("title", "Untitled")
        doc_url = doc.get("url", "")

        # 3-1) Chunking
        chunks = chunk_text(text, chunk_size=chunk_size, overlap=overlap)
        # 3-2) Embedding
        embeddings = embed_chunks(chunks,
                                  api_key=os.getenv("OPENAI_API_KEY", "DUMMY"),
                                  model=os.getenv("EMBEDDING_MODEL", "text-embedding-ada-002"))

        # 3-3) Metadata
        # 각 chunk마다 별도 메타데이터
        for i, emb in enumerate(embeddings):
            meta = {
                "title": doc_title,
                "url": doc_url,
                "chunk_index": i,
                "text_snippet": chunks[i][:50]  # 미리보기
            }
            all_embeddings.append(emb)
            all_metadatas.append(meta)

    # 3-4) 저장
    store.add_documents(all_embeddings, all_metadatas)
    print(f"[FAISS] Stored {len(all_embeddings)} chunk embeddings.")

    # 4) 간단 검색 테스트
    # 쿼리도 임베딩 stubs로 만듦
    query = "휴가 양식 관련 내용"
    query_embedding = embed_chunks([query])[0]  # 한 개 문장만
    results = store.search(query_embedding, top_k=3)

    print("[Search Test] Query:", query)
    for dist, meta in results:
        print(f" - Distance={dist:.2f}, Title={meta.get('title')}, Snippet={meta.get('text_snippet')}")

    print("Chunking & Embedding Test Complete.")

if __name__ == "__main__":
    main()
PYTHON

echo "=== Done! Now you can run the following to test: ==="
echo "  cd project"
echo "  source ../.venv/bin/activate"
echo "  python main.py"

