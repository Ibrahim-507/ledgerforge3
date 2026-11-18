# LedgerForge v1.0.0 - Release notes

## Included
- Departments, employees, salary revisions, attendance, leave (FastAPI, SQLAlchemy, Alembic)
- Payroll engine: 7,340 / 7,340 official rows match
- Payslip PDF, double-entry ledger with reversals, invoices, vendor bills with approval
- Payroll runs (draft, processed, approved, paid), idempotent; tax rules as data; statutory reports
- Trial balance, P&L, balance sheet
- Security: scrypt hashes, JWT 30 min, roles ADMIN / HR / EMPLOYEE, deny-by-default permissions
- Background bulk payroll job, /api/v1, Docker Compose, CI tests
- JSON logs, /health with database check, backup and restore, CSV/Excel export

## NOT included / known limits (honest)
- Books store (ledger, payroll, invoices) is SQLite on a disk/volume, not PostgreSQL
- Demo users share one demo password
- No login-attempt limits yet
- Free hosting may sleep; first request can be slow
- (add anything else you found during the audit)

## Final checks
Paste the output of the five official checks on live data here.
