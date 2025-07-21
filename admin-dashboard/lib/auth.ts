// lib/auth.ts
export const getToken = (): string | null => {
  if (typeof window !== 'undefined') {
    return localStorage.getItem('token') || sessionStorage.getItem('token')
  }
  return null
}

export const setToken = (token: string, rememberMe = false): void => {
  if (typeof window !== 'undefined') {
    if (rememberMe) {
      localStorage.setItem('token', token)
    } else {
      sessionStorage.setItem('token', token)
    }
  }
}

export const removeToken = (): void => {
  if (typeof window !== 'undefined') {
    localStorage.removeItem('token')
    sessionStorage.removeItem('token')
  }
}

export const isAuthenticated = (): boolean => {
  return !!getToken()
}

export const withAuth = async (requestInit: RequestInit): Promise<RequestInit> => {
  const token = getToken()
  if (!token) {
    throw new Error('Authentication token missing')
  }
  
  return {
    ...requestInit,
    headers: {
      ...requestInit.headers,
      'Authorization': `Bearer ${token}`
    }
  }
}