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
