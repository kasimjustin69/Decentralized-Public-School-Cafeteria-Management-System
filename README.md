# Decentralized Public School Cafeteria Management System

A comprehensive blockchain-based solution for managing school cafeteria operations, ensuring transparency, accountability, and compliance with federal nutrition standards.

## System Overview

This system consists of five interconnected smart contracts that manage different aspects of school cafeteria operations:

### 1. Menu Planning Contract (`menu-planning.clar`)
- Coordinates nutritious meal development
- Manages dietary restrictions and allergen information
- Tracks meal approval status and nutritional data
- Handles menu scheduling and rotation

### 2. Food Inventory Tracking Contract (`food-inventory.clar`)
- Manages ingredient purchasing and stock levels
- Tracks expiration dates and food safety
- Monitors supplier information and delivery schedules
- Handles inventory alerts and reordering

### 3. Student Meal Account Contract (`student-accounts.clar`)
- Manages prepaid lunch balances
- Handles free and reduced meal eligibility
- Tracks student meal transactions
- Manages account funding and refunds

### 4. Kitchen Equipment Maintenance Contract (`equipment-maintenance.clar`)
- Schedules appliance repairs and maintenance
- Tracks equipment safety inspections
- Manages maintenance costs and vendor information
- Monitors equipment lifecycle and replacement needs

### 5. Nutrition Compliance Contract (`nutrition-compliance.clar`)
- Ensures meals meet federal school nutrition standards
- Tracks nutritional content and compliance metrics
- Manages audit trails and reporting
- Handles compliance violations and corrections

## Key Features

- **Transparency**: All transactions and decisions are recorded on the blockchain
- **Accountability**: Clear audit trails for all cafeteria operations
- **Compliance**: Automated checks for federal nutrition standards
- **Efficiency**: Streamlined processes for inventory, accounts, and maintenance
- **Safety**: Food safety tracking and equipment maintenance scheduling

## Technical Architecture

- **Blockchain**: Stacks blockchain using Clarity smart contracts
- **Data Storage**: On-chain storage for critical data, off-chain for large files
- **Access Control**: Role-based permissions for different user types
- **Integration**: Designed for integration with existing school management systems

## User Roles

- **School Administrator**: Full system access and configuration
- **Cafeteria Manager**: Daily operations and menu management
- **Kitchen Staff**: Inventory updates and meal preparation tracking
- **Nutrition Coordinator**: Compliance monitoring and reporting
- **Students/Parents**: Account balance viewing and meal history

## Getting Started

1. Install dependencies: `npm install`
2. Run tests: `npm test`
3. Deploy contracts using Clarinet: `clarinet deploy`
4. Configure initial system parameters through admin functions

## Contract Interactions

Each contract operates independently but shares common data structures for seamless integration. The system is designed to be modular, allowing schools to implement individual contracts as needed.

## Compliance Standards

The system is designed to meet:
- USDA School Meal Programs requirements
- Child Nutrition Act standards
- Local health department regulations
- Food safety and handling protocols

## Security Considerations

- Multi-signature requirements for critical operations
- Role-based access control
- Input validation and error handling
- Audit logging for all transactions
