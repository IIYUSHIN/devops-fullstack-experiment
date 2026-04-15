import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [currentTime, setCurrentTime] = useState(new Date().toLocaleTimeString());
  const [buildInfo] = useState({
    version: process.env.REACT_APP_VERSION || '1.0.0',
    environment: process.env.REACT_APP_ENV || 'development',
    buildDate: process.env.REACT_APP_BUILD_DATE || new Date().toISOString().split('T')[0],
  });

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date().toLocaleTimeString());
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const features = [
    {
      icon: '🐳',
      title: 'Docker Multi-Stage Build',
      description: 'Production-optimized image under 100MB using Node.js build stage and Nginx alpine runtime.',
      details: ['Multi-stage Dockerfile', 'Nginx with gzip compression', 'Cached static assets', 'Alpine-based image'],
    },
    {
      icon: '⚡',
      title: 'CI/CD Pipeline',
      description: 'Automated testing, building, and deployment using GitHub Actions workflows.',
      details: ['Auto-test on PR', 'Docker build & push to GHCR', 'Dual tagging (latest + SHA)', 'Slack notifications'],
    },
    {
      icon: '☁️',
      title: 'AWS Deployment',
      description: 'Highly available deployment with load balancing and auto-scaling on AWS ECS Fargate.',
      details: ['VPC across 2 AZs', 'ECS Fargate cluster', 'Application Load Balancer', 'Auto-scaling (2–4 tasks)'],
    },
  ];

  return (
    <div className="app">
      {/* Animated background */}
      <div className="bg-grid" />
      <div className="bg-glow bg-glow-1" />
      <div className="bg-glow bg-glow-2" />

      {/* Header */}
      <header className="header">
        <div className="header-badge">
          <span className="pulse-dot" />
          <span>Live</span>
        </div>
        <h1 className="header-title">
          DevOps <span className="gradient-text">Full-Stack</span> Experiment
        </h1>
        <p className="header-subtitle">
          Docker • CI/CD • AWS Infrastructure
        </p>
      </header>

      {/* Status bar */}
      <section className="status-bar">
        <div className="status-item">
          <span className="status-label">Environment</span>
          <span className="status-value env-badge">{buildInfo.environment}</span>
        </div>
        <div className="status-item">
          <span className="status-label">Version</span>
          <span className="status-value">{buildInfo.version}</span>
        </div>
        <div className="status-item">
          <span className="status-label">Build Date</span>
          <span className="status-value">{buildInfo.buildDate}</span>
        </div>
        <div className="status-item">
          <span className="status-label">Server Time</span>
          <span className="status-value time-value">{currentTime}</span>
        </div>
      </section>

      {/* Feature cards */}
      <main className="features">
        {features.map((feature, index) => (
          <div className="feature-card" key={index} style={{ animationDelay: `${index * 0.15}s` }}>
            <div className="card-icon">{feature.icon}</div>
            <h2 className="card-title">{feature.title}</h2>
            <p className="card-desc">{feature.description}</p>
            <ul className="card-details">
              {feature.details.map((detail, i) => (
                <li key={i}>
                  <span className="check-icon">✓</span>
                  {detail}
                </li>
              ))}
            </ul>
            <div className="card-number">Part {index + 1}</div>
          </div>
        ))}
      </main>

      {/* Architecture diagram section */}
      <section className="architecture">
        <h2 className="section-title">Deployment Pipeline</h2>
        <div className="pipeline">
          <div className="pipeline-step">
            <div className="step-icon">📝</div>
            <div className="step-label">Code Push</div>
          </div>
          <div className="pipeline-arrow">→</div>
          <div className="pipeline-step">
            <div className="step-icon">🧪</div>
            <div className="step-label">Run Tests</div>
          </div>
          <div className="pipeline-arrow">→</div>
          <div className="pipeline-step">
            <div className="step-icon">🐳</div>
            <div className="step-label">Docker Build</div>
          </div>
          <div className="pipeline-arrow">→</div>
          <div className="pipeline-step">
            <div className="step-icon">📦</div>
            <div className="step-label">Push to GHCR</div>
          </div>
          <div className="pipeline-arrow">→</div>
          <div className="pipeline-step">
            <div className="step-icon">☁️</div>
            <div className="step-label">Deploy to AWS</div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="footer">
        <p>DevOps Full-Stack Experiment &copy; {new Date().getFullYear()}</p>
        <p className="footer-tech">React 18 • Docker • GitHub Actions • AWS ECS • Terraform</p>
      </footer>
    </div>
  );
}

export default App;
