import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { api, Author } from '../services/api';

function AuthorDetail() {
  const { id } = useParams<{ id: string }>();
  const [author, setAuthor] = useState<Author | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (id) {
      api.getAuthor(parseInt(id))
        .then(setAuthor)
        .catch(err => setError(err.message))
        .finally(() => setLoading(false));
    }
  }, [id]);

  if (loading) return <div className="loading">Loading...</div>;
  if (error) return <div className="error">Error: {error}</div>;
  if (!author) return <div className="error">Author not found</div>;

  return (
    <div className="page-container">
      <div className="detail-view">
      <Link to="/authors" className="back-link">← Back to Authors</Link>
      
      <div className="author-detail">
        <h2>{author.name}</h2>
        
        <div className="detail-grid">
          {author.country && (
            <div className="detail-item">
              <strong>Country:</strong>
              <span>🌍 {author.country}</span>
            </div>
          )}
        </div>
        
        {author.bio && (
          <div className="bio-section">
            <h3>Biography</h3>
            <p>{author.bio}</p>
          </div>
        )}
        
        <div className="books-section">
          <h3>Books by {author.name}</h3>
          <div className="book-grid">
            {author.books.map(book => (
              <Link to={`/books/${book.id}`} key={book.id} className="book-card">
                <h4>{book.title}</h4>
                <p className="isbn">ISBN: {book.isbn}</p>
                <p className="price">${book.price.toFixed(2)}</p>
              </Link>
            ))}
          </div>
        </div>
      </div>
      </div>
    </div>
  );
}

export default AuthorDetail;
