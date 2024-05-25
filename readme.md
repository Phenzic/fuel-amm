
# AMM Contract and Frontend Development Log

## Project Overview

This project involves building an Automated Market Maker (AMM) smart contract using Sway on the Fuel network, along with a React frontend for interacting with the contract. This log documents issues and friction points encountered during development to provide feedback for improving the Fuel tools and documentation.

## Contract Development

### Modular Importing:
- **Issue**: Error "Module 'src20' could not be found"
- **Resolution**: Verified the `src20` contract was in the correct directory and properly referenced in the import statements.
- **Notes**: When importing custom sway libraries of contract from the same directory, always use the `mod` key, hence the use of `mod src20` in the `main.sw` contract.

### Building Contract ABI:

- **Issue**: [Description of the issue]
- **Resolution**: [Steps taken to resolve the issue]
- **Notes**: [Additional notes]


### Function Implementation

- **Issue**: [Description of the issue]
- **Resolution**: [Steps taken to resolve the issue]
- **Notes**: [Additional notes]

### Deployment

- **Issue**: [Description of the issue]
- **Resolution**: [Steps taken to resolve the issue]
- **Notes**: [Additional notes]



## Frontend Development

### Initial Setup

- **Issue**: [Description of the issue]
- **Resolution**: [Steps taken to resolve the issue]
- **Notes**: [Additional notes]

### Wallet Integration

- **Issue**: [Description of the issue]
- **Resolution**: [Steps taken to resolve the issue]
- **Notes**: [Additional notes]

### Contract Interaction

- **Issue**: [Description of the issue]
- **Resolution**: [Steps taken to resolve the issue]
- **Notes**: [Additional notes]

### UI/UX Challenges

- **Issue**: [Description of the issue]
- **Resolution**: [Steps taken to resolve the issue]
- **Notes**: [Additional notes]


## Conclusion

This log documents the development process, highlighting key issues and their resolutions. The aim is to provide constructive feedback to improve the Fuel ecosystem for future developers.


after deployment 

```
  Finished debug in 53.089369005s
  contract AMM-contract
      Bytecode size: 49380 bytes

Please provide the password of your encrypted wallet vault at "/home/teggyg/.fuel/wallets/.wallet":

Account 0 -- fuel1463xealmz7zsy37zwf8lelmtj8esqhlw30xaalcs4mqypqva8z2qr6llqu:
  Asset ID                                                           Amount
  0000000000000000000000000000000000000000000000000000000000000000 2000000

Please provide the index of account to use for signing: 0
Do you agree to sign this transaction with fuel1463xealmz7zsy37zwf8lelmtj8esqhlw30xaalcs4mqypqva8z2qr6llqu? [y/N]: y


Contract AMM-contract Deployed!

Network: https://beta-5.fuel.network
Contract ID: 0xf06f99125673ee37e2edef52cfa798daccb4603914cd1147057310d01c3b6677        
Deployed in block 0xb196fe94269dd6049ae4f1c10ea66be89a090c396807e4cae2b09e73381a7424

```