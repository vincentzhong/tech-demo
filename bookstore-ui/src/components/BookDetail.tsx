import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { api, Book } from '../services/api';

function BookDetail() {
  const { id } = useParams<{ id: string }>();
  const [book, setBook] = useState<Book | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (id) {
      api.getBook(parseInt(id))
        .then(setBook)
        .catch(err => setError(err.message))
        .finally(() => setLoading(false));
    }
  }, [id]);

  if (loading) return <div className="loading">Loading...</div>;
  if (error) return <div className="error">Error: {error}</div>;
  if (!book) return <div className="error">Book not found</div>;

  return (
    <div className="page-container">
      <div className="detail-view">
      <Link to="/" className="back-link">← Back to Books</Link>
      
      <div className="book-detail">
        <h2>{book.title}</h2>
        
        <div className="detail-grid">
          <div className="detail-item">
            <strong>Author:</strong>
            <Link to={`/authors/${book.author.id}`}>{book.author.name}</Link>
          </div>
          
          <div className="detail-item">
            <strong>ISBN:</strong>
            <span>{book.isbn}</span>
          </div>
          
          <div className="detail-item">
            <strong>Price:</strong>
            <span className="price">${book.price.toFixed(2)}</span>
          </div>
          
          <div className="detail-item">
            <strong>Published:</strong>
            <span>{new Date(book.publishedDate).toLocaleDateString()}</span>
          </div>
        </div>
      </div>
      </div>
    </div>
  );
}

export default BookDetail;
