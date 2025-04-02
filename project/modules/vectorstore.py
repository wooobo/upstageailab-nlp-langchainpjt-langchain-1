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
