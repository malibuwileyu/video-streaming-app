# ReelAI Backend

FastAPI backend for the ReelAI educational video platform.

## Setup

1. Create virtual environment:
```bash
python -m venv venv
```

2. Activate virtual environment:
```bash
# On Linux/Mac:
source venv/bin/activate

# On Windows:
.\venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

## Project Structure

```
backend/
├── app/                # Application package
│   ├── api/           # API endpoints
│   ├── core/          # Core functionality
│   ├── models/        # Data models
│   └── services/      # Business logic
├── tests/             # Test files
│   ├── unit/         # Unit tests
│   └── integration/  # Integration tests
├── alembic/           # Database migrations
├── requirements.txt   # Project dependencies
└── README.md         # This file
```

## Development

1. Start the development server:
```bash
uvicorn app.main:app --reload
```

2. Run tests:
```bash
pytest
```

## API Documentation

Once the server is running, view the API documentation at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
