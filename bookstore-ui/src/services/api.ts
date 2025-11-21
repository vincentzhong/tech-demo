const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://api.zhong.nz';

// Helper function to get auth headers
const getAuthHeaders = (): HeadersInit => {
  const token = localStorage.getItem('auth_token');
  return {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };
};

// Helper function to handle API responses
const handleResponse = async (response: Response) => {
  if (response.status === 401) {
    // Token expired or invalid, clear it
    localStorage.removeItem('auth_token');
    window.location.href = '/login';
    throw new Error('Unauthorized. Please login again.');
  }
  
  if (!response.ok) {
    const error = await response.json().catch(() => ({ message: 'Request failed' }));
    throw new Error(error.message || 'Request failed');
  }
  
  return response.json();
};

export interface Book {
  id: number;
  title: string;
  isbn: string;
  publishedDate: string;
  price: number;
  authorId: number;
  createdAt: string;
  updatedAt?: string;
  author: Author;
}

export interface Author {
  id: number;
  name: string;
  bio?: string;
  country?: string;
  createdAt: string;
  updatedAt?: string;
  books: Book[];
}

export interface LoginResponse {
  token: string;
  expiresAt: string;
  username: string;
  role: string;
}

export interface CurrentUser {
  id: number;
  username: string;
  email: string;
  role: string;
}

export const api = {
  // Authentication
  async login(username: string, password: string): Promise<LoginResponse> {
    const response = await fetch(`${API_BASE_URL}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password }),
    });
    return handleResponse(response);
  },

  async getCurrentUser(): Promise<CurrentUser> {
    const response = await fetch(`${API_BASE_URL}/api/auth/me`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  // Books
  async getBooks(): Promise<Book[]> {
    const response = await fetch(`${API_BASE_URL}/api/books`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  async getBook(id: number): Promise<Book> {
    const response = await fetch(`${API_BASE_URL}/api/books/${id}`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  // Authors
  async getAuthors(): Promise<Author[]> {
    const response = await fetch(`${API_BASE_URL}/api/authors`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  async getAuthor(id: number): Promise<Author> {
    const response = await fetch(`${API_BASE_URL}/api/authors/${id}`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  async getAuthorBooks(id: number): Promise<Book[]> {
    const response = await fetch(`${API_BASE_URL}/api/authors/${id}/books`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },
};
