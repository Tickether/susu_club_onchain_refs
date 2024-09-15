// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;



import { Ownable } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/access/Ownable.sol";

/// @title susu.club onchain referral tracking V1
/// @notice This onchain referral sysytem stores invite heirachy & returns a list of invites claimed from a referrer.
/// @author Geeloko

contract SusuClubOnchainRefs is Ownable {
    constructor(address initialOwner) Ownable(initialOwner) {}
    
    mapping(address => address) public referrerOf;
    mapping(address => address[]) public invitesClaimedFrom;
    

    function claimInvite(address referrer, address invited) external onlyOwner{
        require(referrer != invited, "Invite Paradox");
        require(referrerOf[invited] == address(0), "Invite already claimed");
        referrerOf[invited] = referrer;
        invitesClaimedFrom[referrer].push(invited);
    }

    
    function getInvitesClaimedFrom(address referrer) external view returns(address[] memory)  {
        return invitesClaimedFrom[referrer];
    }
    
    
}
