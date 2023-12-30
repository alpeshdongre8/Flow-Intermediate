import FungibleToken from 0x05
import AlpToken from 0x05

transaction (receiver: Address, amount: UFix64) {

    prepare (signer: AuthAccount) {
        // Borrow the AlpToken admin reference
        let minter = signer.borrow<&AlpToken.Admin>(from: AlpToken.AdminStorage)
        ?? panic("You are not the AlpToken admin")

        // Borrow the receiver's AlpToken Vault capability
        let receiverVault = getAccount(receiver)
            .getCapability<&AlpToken.Vault{FungibleToken.Receiver}>(/public/Vault)
            .borrow()
        ?? panic("Error: Check your AlpToken Vault status")
    }

    execute {
        // Mint AlpTokens using the admin minter reference
        let mintedTokens <- minter.mint(amount: amount)

        // Deposit minted tokens into the receiver's AlpToken Vault
        receiverVault.deposit(from: <-mintedTokens)

        log("Minted and deposited Malima tokens successfully")
        log(amount.toString().concat(" Tokens minted and deposited"))
    }
}