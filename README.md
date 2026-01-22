# Book Lending DApp (Smart Contract Backend)

Live : https://booklendingdapp.vercel.app/

A **decentralized library/book lending system** built on **Ethereum (EVM)** using **Solidity** and **Foundry**. This smart contract allows users to list books, rent them with deposits, calculate late penalties, and withdraw funds securely. Includes owner/admin controls like pausing the contract and managing books.

---

## 📦 Features

- **Book Management**
  - List a new book with deposit and rent fee
  - Unlist a book
  - Update rent fee and deposit
- **Rental Management**
  - Rent a book by paying deposit + rent
  - Return a book with late penalty calculation
  - Automatic penalty transfer to book owner
  - Clear rental state after return to prevent re-rent issues
- **Funds & Withdrawals**
  - Pending withdrawals for users and book owners
  - Safe withdrawals with `nonReentrant` modifier
- **Admin Controls**
  - Pause and unpause contract using `Pausable`
- **Events**
  - `BookListed`, `BookUnlisted`, `BookUpdated`
  - `BookRented`, `BookReturned`
  - `Withdrawal`

---

## 🛠️ Tech Stack

- **Solidity:** 0.8.24
- **Foundry:** For compiling, testing, and deploying
- **OpenZeppelin:** `Ownable`, `Pausable`, `ReentrancyGuard` for secure patterns
- **Ethereum Testnet:** Sepolia

---

## 📄 Deployment

- **Deployed on Sepolia Testnet:**  
[BookRental Contract on Sepolia Etherscan](https://sepolia.etherscan.io/address/0xfad916cA4287989415a1Ec8689e6800bBBBA4FF9)

- **Deploy Script:** `script/Deploy.s.sol`  
- **Broadcasted using Foundry CLI**:

```bash
forge script script/Deploy.s.sol:DeployBookRental \
  --rpc-url "$SEPOLIA_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast

```

---

## 🔒 Security

- Reentrancy safe with ReentrancyGuard
- Owner-only actions protected by Ownable
- Pause/unpause functionality for emergency control
- Proper deposit and penalty accounting to prevent fund loss

---

