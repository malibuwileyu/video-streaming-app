import pytest
from httpx import AsyncClient
# TODO: Import FastAPI app once created

@pytest.fixture
async def client():
    # TODO: Initialize app
    # async with AsyncClient(app=app, base_url="http://test") as client:
    #     yield client
    pass

@pytest.fixture
def mock_firebase():
    # TODO: Create mock Firebase client
    # mock_client = MockFirebaseAdmin()
    # yield mock_client
    pass 