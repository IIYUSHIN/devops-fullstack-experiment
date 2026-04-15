import { render, screen } from '@testing-library/react';
import App from './App';

test('renders the main heading', () => {
  render(<App />);
  const headings = screen.getAllByText(/Full-Stack/i);
  expect(headings.length).toBeGreaterThan(0);
});

test('renders all three feature cards', () => {
  render(<App />);
  expect(screen.getByText(/Docker Multi-Stage Build/i)).toBeInTheDocument();
  expect(screen.getByText(/CI\/CD Pipeline/i)).toBeInTheDocument();
  expect(screen.getByText(/AWS Deployment/i)).toBeInTheDocument();
});

test('renders pipeline section', () => {
  render(<App />);
  expect(screen.getByText(/Deployment Pipeline/i)).toBeInTheDocument();
  expect(screen.getByText(/Code Push/i)).toBeInTheDocument();
});

test('renders environment info', () => {
  render(<App />);
  expect(screen.getByText(/Environment/i)).toBeInTheDocument();
  expect(screen.getByText(/Version/i)).toBeInTheDocument();
});
