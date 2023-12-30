import FungibleToken from 0x05
import AlpToken from 0x05

pub fun main(account: Address) {

    // Attempt to borrow PublicVault capability
    let publicVault: &AlpToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, AlpToken.CollectionPublic}? =
        getAccount(account).getCapability(/public/Vault)
            .borrow<&AlpToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, AlpToken.CollectionPublic}>()

    if (publicVault == nil) {
        // Create and link an empty vault if capability is not present
        let newVault <- AlpToken.createEmptyVault()
        getAuthAccount(account).save(<-newVault, to: /storage/VaultStorage)
        getAuthAccount(account).link<&AlpToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, AlpToken.CollectionPublic}>(
            /public/Vault,
            target: /storage/VaultStorage
        )
        log("Empty vault created")
        
        // Borrow the vault capability again to display its balance
        let retrievedVault: &AlpToken.Vault{FungibleToken.Balance}? =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&AlpToken.Vault{FungibleToken.Balance}>()
        log(retrievedVault?.balance)
    } else {
        log("Vault already exists and is properly linked")
        
        // Borrow the vault capability for further checks
        let checkVault: &AlpToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, AlpToken.CollectionPublic} =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&AlpToken.Vault{FungibleToken.Balance, FungibleToken.Receiver, AlpToken.CollectionPublic}>()
                ?? panic("Vault capability not found")
        
        // Check if the vault's UUID is in the list of vaults
        if AlpToken.vaults.contains(checkVault.uuid) {
            log(publicVault?.balance)
            log("This is a AlpToken vault")
        } else {
            log("This is not a AlpToken vault")
        }
    }
}