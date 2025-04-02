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

