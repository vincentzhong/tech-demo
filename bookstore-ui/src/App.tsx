import { BrowserRouter, Routes, Route, Link, Navigate } from 'react-router-dom'
import { useAuth } from './contexts/AuthContext'
import Login from './components/Login'
import BookList from './components/BookList'
import BookDetail from './components/BookDetail'
import AuthorList from './components/AuthorList'
import AuthorDetail from './components/AuthorDetail'
import './App.css' 

// Protected Route Component
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div style={{ 
        display: 'flex', 
        alignItems: 'center', 
        justifyContent: 'center', 
        minHeight: '100vh',
        fontSize: '18px',
        color: '#666'
      }}>
        Loading...
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return <>{children}</>;
}

function App() {
  const { isAuthenticated, user, logout } = useAuth();
  return (
    <BrowserRouter>
      <div className="app">
        {isAuthenticated && (
          <nav className="navbar">
            <div className="container">
              <h1>Bookstore</h1>
              <div className="nav-links">
                <Link to="/">Books</Link>
                <Link to="/authors">Authors</Link>
                <span className="user-info">{user?.username}</span>
                <button onClick={logout} className="logout-button">Logout</button>
              </div>
            </div>
          </nav>
        )}
        
        <main>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route path="/" element={
              <ProtectedRoute>
                <BookList />
              </ProtectedRoute>
            } />
            <Route path="/books/:id" element={
              <ProtectedRoute>
                <BookDetail />
              </ProtectedRoute>
            } />
            <Route path="/authors" element={
              <ProtectedRoute>
                <AuthorList />
              </ProtectedRoute>
            } />
            <Route path="/authors/:id" element={
              <ProtectedRoute>
                <AuthorDetail />
              </ProtectedRoute>
            } />
          </Routes>
        </main>
        
        {isAuthenticated && (
          <footer className="footer">
            <div className="container">
              <p>&copy; 2024 Bookstore. Built with React + .NET 9</p>
            </div>
          </footer>
        )}
      </div>
    </BrowserRouter>
  )
}

export default App
