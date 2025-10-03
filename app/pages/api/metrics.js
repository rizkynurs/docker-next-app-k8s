// Expose Prometheus metrics
const client = require('prom-client');

// Create a registry and collect default metrics
const register = new client.Registry();
client.collectDefaultMetrics({ register });

export default async function handler(req, res) {
  res.setHeader('Content-Type', register.contentType);
  const metrics = await register.metrics();
  res.status(200).send(metrics);
}
