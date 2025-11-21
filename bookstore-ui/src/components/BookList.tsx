import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { api, Book } from '../services/api';

function BookList() {
  const [books, setBooks] = useState<Book[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    api.getBooks()
      .then(setBooks)
      .catch(err => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="loading">Loading books...</div>;
  if (error) return <div className="error">Error: {error}</div>;

  return (
    <div className="page-container">
      <h2>📖 Books Collection</h2>
      <div className="book-grid">
        {books.map(book => (
          <Link to={`/books/${book.id}`} key={book.id} className="book-card">
            <h3>{book.title}</h3>
            <p className="author">by {book.author.name}</p>
            <p className="isbn">ISBN: {book.isbn}</p>
            <p className="price">${book.price.toFixed(2)}</p>
            <p className="date">
              Published: {new Date(book.publishedDate).toLocaleDateString()}
            </p>
          </Link>
        ))}
      </div>
    </div>
  );
}

export default BookList;
