import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { api, Author } from '../services/api';

function AuthorList() {
  const [authors, setAuthors] = useState<Author[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    api.getAuthors()
      .then(setAuthors)
      .catch(err => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="loading">Loading authors...</div>;
  if (error) return <div className="error">Error: {error}</div>;

  return (
    <div className="page-container">
      <h2>✍️ Authors</h2>
      <div className="author-grid">
        {authors.map(author => (
          <Link to={`/authors/${author.id}`} key={author.id} className="author-card">
            <h3>{author.name}</h3>
            {author.country && <p className="country">🌍 {author.country}</p>}
            {author.bio && <p className="bio">{author.bio.substring(0, 100)}...</p>}
            <p className="book-count">{author.books.length} books</p>
          </Link>
        ))}
      </div>
    </div>
  );
}

export default AuthorList;
