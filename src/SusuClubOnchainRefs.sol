// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;



import { Ownable } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/access/Ownable.sol";
import { IERC20 } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.0/contracts/token/ERC20/IERC20.sol";

/// @title susu.club onchain referral tracking V1.1
/// @notice This onchain referral sysytem stores invite heirachy & returns a list of invites claimed from a referrer.
/// @author Geeloko

contract SusuClubOnchainRefs is Ownable {
    IERC20 public USDC = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913); // ERC-20 token contract
    uint256 public inviteBonusAmount = 1 * 10**6; // Define the bonus amount in tokens (adjust as needed)
    uint256 public memberBonusAmount = 2 * 10**6;


    
    uint256 public memberClaims;
    uint256 public MAX_MEMBER_CLAIMS = 1000;


    uint256 public inviteClaims;
    uint256 public MAX_INVITE_CLAIMS = 3000;

    constructor(address initialOwner) Ownable(initialOwner) {}

    struct Invited {
        address walletAddress;
        bool rewarded;
    }
    
    
    mapping(address => Invited) public invited;
    mapping(address => address) public referrerOf;
    mapping(address => bool) public memberRewarded;
    mapping(address => address[]) public invitesClaimedFrom;

    

    function setTokenAddress(address newTokenAddress) external onlyOwner {
        require(newTokenAddress != address(0), "Invalid token address");
        USDC = IERC20(newTokenAddress);
    }

    function setMaxClaims(uint256 maxMemberClaims, uint256 maxInviteClaims) external onlyOwner {
        MAX_MEMBER_CLAIMS = maxMemberClaims;
        MAX_INVITE_CLAIMS = maxInviteClaims;
    }

    function claimInvite(address referrer, address invitee) external onlyOwner{
        require(referrer != invitee, "Invite Paradox");
        require(referrerOf[invitee] == address(0), "Invite already claimed");
        referrerOf[invitee] = referrer;
        Invited memory newInvitee = Invited({
            walletAddress: invitee,
            rewarded: false // Assuming default values
        });
        invitesClaimedFrom[referrer].push(invitee);
        invited[invitee] = newInvitee;
    }

    
    function getInvitesClaimedFrom(address referrer) external view returns(address[] memory) {
        return invitesClaimedFrom[referrer];
    }


    function updateInviteRewarded(
        address invitee
    ) external onlyOwner {
        // Check if the invitee exists in the invited mapping
        require(invited[invitee].walletAddress != address(0), "Invitee not found");
        
        // Update the `invited` mapping
        invited[invitee].rewarded = true;
    }

    function claimInviteBonus(address[] calldata invitees) external onlyOwner {
        require(invitees.length > 0, "No invitees provided");
        require(inviteClaims + invitees.length <= MAX_INVITE_CLAIMS, "max claim reached");

        // Get the referrer of the first invitee
        address referrer = referrerOf[invitees[0]];
        require(referrer != address(0), "Invalid referrer");

        uint256 totalRequired = inviteBonusAmount * invitees.length;
        require(USDC.balanceOf(address(this)) >= totalRequired, "Insufficient contract token balance");
        
        // First loop: Validate all invitees
        for (uint256 i = 0; i < invitees.length; i++) {
            address invitee = invitees[i];
            
            // Ensure all invitees have the same referrer
            require(referrerOf[invitee] == referrer, "Invitees have different referrers");
            

            // Check if invitee has already claimed the reward
            require(!invited[invitee].rewarded, "Bonus already claimed");

        }
        // Second loop: Update state and perform transfer
        for (uint256 i = 0; i < invitees.length; i++) {
            address invitee = invitees[i];
            
            // Mark each invitee as rewarded
            invited[invitee].rewarded = true;
        }
        inviteClaims += invitees.length;

        // Transfer the total reward amount to the referrer in one go
        USDC.transfer(referrer, totalRequired);
        
    }


    function claimMemberBonus(address member) external onlyOwner {
        require(!memberRewarded[member], "Member bonus already claimed");
        require(memberClaims + 1 <= MAX_MEMBER_CLAIMS, "max claim reached");

        // Get the referrer of the member
        address referrer = referrerOf[member];

        if (referrer != address(0)) {
            // Check if the contract has enough token balance to pay the bonus
            require(USDC.balanceOf(address(this)) >= memberBonusAmount + inviteBonusAmount, "Insufficient contract token balance");

            // Mark the invitee as rewarded
            memberRewarded[member] = true;
            memberClaims += 1;

            USDC.transfer(member, memberBonusAmount + inviteBonusAmount);
        }
        if (referrer == address(0)) {
            // Check if the contract has enough token balance to pay the bonus
            require(USDC.balanceOf(address(this)) >= memberBonusAmount, "Insufficient contract token balance");

            // Mark the invitee as rewarded
            memberRewarded[member] = true;
            memberClaims += 1;

            USDC.transfer(member, memberBonusAmount);
        }
    }

    function ownerWithdraw() external onlyOwner {
    
        uint256 contractBalance = USDC.balanceOf(address(this));

        // Check if the contract has enough token balance to pay the bonus
        require(contractBalance > 0, "Insufficient contract token balance");


        // Transfer the bonus amount to the referrer
        USDC.transfer(msg.sender, contractBalance);
    }
    
    // Function to reject any incoming Ether to this contract
    receive() external payable {
        revert("This contract does not accept Ether.");
    }

    // Fallback function to handle unexpected calls to the contract
    fallback() external payable {
        revert("This contract does not accept direct calls.");
    }
    
}
