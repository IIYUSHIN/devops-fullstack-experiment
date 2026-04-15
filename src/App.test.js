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

test('renders pipeline steps', () => {
  render(<App />);
  expect(screen.getByText(/Code Push/i)).toBeInTheDocument();
  expect(screen.getByText(/Run Tests/i)).toBeInTheDocument();
  const dockerBuildElements = screen.getAllByText(/Docker Build/i);
  expect(dockerBuildElements.length).toBeGreaterThan(0);
  expect(screen.getByText(/Push to GHCR/i)).toBeInTheDocument();
  expect(screen.getByText(/Deploy to AWS/i)).toBeInTheDocument();
});

test('renders environment info', () => {
  render(<App />);
  expect(screen.getByText(/Environment/i)).toBeInTheDocument();
  expect(screen.getByText(/Version/i)).toBeInTheDocument();
});
