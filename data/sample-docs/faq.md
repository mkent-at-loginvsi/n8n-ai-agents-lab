# Frequently Asked Questions - DataSync Pro

## General Questions

### What is DataSync Pro?
DataSync Pro is an enterprise-grade data synchronization platform that enables real-time data replication between databases, data warehouses, and cloud services. It's designed for organizations that need reliable, low-latency data movement across their infrastructure.

### What databases does DataSync Pro support?
DataSync Pro supports over 50 database types including:
- Relational: PostgreSQL, MySQL, MariaDB, Oracle, SQL Server, SQLite
- NoSQL: MongoDB, Cassandra, DynamoDB, Redis, Elasticsearch
- Cloud Data Warehouses: Snowflake, BigQuery, Redshift, Databricks
- File Systems: S3, Azure Blob Storage, Google Cloud Storage

### How does real-time synchronization work?
DataSync Pro uses Change Data Capture (CDC) technology to monitor source databases for changes. When a change is detected (insert, update, delete), it's immediately captured, optionally transformed, and applied to the target system. This typically happens within 100-500 milliseconds depending on network conditions.

## Pricing

### How much does DataSync Pro cost?
DataSync Pro offers three pricing tiers:
- **Starter**: $299/month - Up to 5 connections, 1 million records/day
- **Professional**: $999/month - Up to 25 connections, 10 million records/day
- **Enterprise**: Custom pricing - Unlimited connections, custom SLAs

### Is there a free trial?
Yes! We offer a 14-day free trial of the Professional tier. No credit card required. Sign up at https://datasyncpro.example.com/trial

### What payment methods do you accept?
We accept all major credit cards, ACH transfers, and wire transfers. Enterprise customers can request invoice-based billing with NET-30 terms.

## Technical Questions

### What are the system requirements?
Minimum requirements:
- CPU: 4 cores
- RAM: 8GB (16GB recommended)
- Disk: 50GB SSD
- OS: Linux (Ubuntu 20.04+, RHEL 8+), Docker

### Can I run DataSync Pro in Kubernetes?
Yes! We provide official Helm charts for Kubernetes deployment. See our documentation at https://docs.datasyncpro.example.com/kubernetes

### How do I handle schema changes?
DataSync Pro automatically detects schema changes in source databases. You can configure it to:
1. Auto-apply changes to target (default for additive changes)
2. Pause and notify for review
3. Apply custom transformation rules

### What's the maximum throughput?
DataSync Pro can handle up to 100,000 records per second per connection on recommended hardware. For higher throughput requirements, contact our sales team about clustered deployments.

## Security

### Is my data encrypted?
Yes, DataSync Pro encrypts all data:
- In transit: TLS 1.3 encryption for all connections
- At rest: AES-256 encryption for cached data
- Credentials: Encrypted using industry-standard key management

### Does DataSync Pro store my data?
DataSync Pro operates as a pass-through system. Data is cached only temporarily during transformation and is never persisted beyond the synchronization process. All cache is cleared immediately after successful delivery.

### Is DataSync Pro SOC 2 compliant?
Yes, DataSync Pro has achieved SOC 2 Type II certification. Contact security@datasyncpro.example.com for our latest audit reports.

## Troubleshooting

### Why is my sync job showing "Pending"?
Jobs may show "Pending" status when:
1. Waiting for source database connection
2. Target system is temporarily unavailable
3. Rate limiting is being applied
4. Resource constraints on the DataSync server

Check the job logs for specific details.

### How do I resolve "Authentication Failed" errors?
Authentication errors usually indicate:
1. Incorrect credentials - Verify username and password
2. Expired credentials - Rotate API keys or passwords
3. IP restrictions - Ensure DataSync server IP is whitelisted
4. Permission changes - Verify database user permissions

### What should I do if data is missing?
If you notice missing records:
1. Check the job's error log for failed records
2. Verify filter conditions aren't excluding data
3. Ensure source table has a reliable timestamp or primary key
4. Enable detailed logging and re-sync the affected time range

## Support

### How do I contact support?
- Email: support@datasyncpro.example.com
- Portal: https://support.datasyncpro.example.com
- Phone (Enterprise): 1-800-DATASYNC

### What are your support hours?
- Starter: Business hours (9 AM - 5 PM PT, Monday-Friday)
- Professional: Extended hours (6 AM - 10 PM PT, Monday-Saturday)
- Enterprise: 24/7/365 with dedicated support engineer

### Where can I find documentation?
Full documentation is available at https://docs.datasyncpro.example.com including:
- Getting started guides
- API reference
- Best practices
- Troubleshooting guides
- Video tutorials
