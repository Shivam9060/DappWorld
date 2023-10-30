Problem 1:-

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PalindromeChecker {

    function isPalindrome(string memory str) public pure returns (bool) {
        bytes memory strBytes = bytes(str);
        uint len = strBytes.length;

        if (len==0) {
            return true;
        }
        
        uint i = 0;
        uint j = len-1;
        
        while (i<j) {
            while (i<len && !isAlphanumeric(strBytes[i])) {
                i++;
            }
            
            while (j>0 && !isAlphanumeric(strBytes[j])) {
                j--;
            }
            
            if (i<j && toLowerCase(strBytes[i]) != toLowerCase(strBytes[j])) {
                return false;
            }
            
            i++;
            j--;
        }
        
        return true;
    }
    
    function isAlphanumeric(bytes1 char) internal pure returns (bool) {
        return (char >= bytes1('a') && char <= bytes1('z')) || (char >= bytes1('A') && char <= bytes1('Z')) || (char >= bytes1('0') && char <= bytes1('9'));
    }
    
    function toLowerCase(bytes1 char) internal pure returns (bytes1) {
        if (char >= bytes1('A') && char <= bytes1('Z')) {
            return bytes1(uint8(char) + 32);
        }
        return char;
    }
}


Problem 2:-

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LotteryPool {

    address[] participants;
    mapping(address=>bool) participated;
    address winner;
    
    // For participants to enter the pool
    function enter() public payable {
        require(msg.value == 0.1 ether,"Send only 0.1 ether to participate");
        require(!participated[msg.sender], "You are already participated");

        participated[msg.sender]=true;
        participants.push(msg.sender);

        if(participants.l == 5){
            uint8 index = uint8((uint(keccak256(abi.encodePacked(block.number, block.timestamp, participants)))) % 5);
            winner = participants[index];
            payable(winner).transfer(address(this).balance);
            delete participated;
            delete participants;
        }

    }

    // To view participants in current pool
    function viewParticipants() public view returns (address[] memory, uint) {
        return (participants,participants.length);
    }

    // To view winner of last lottery
    function viewPreviousWinner() public view returns (address) {
        require(winner!= address(0),"Lottery has not completed yet");
        return winner;
    }
}


Problem 3:-

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LotteryPool {

    address immutable owner;
    address[] participants;
    mapping(address=>bool) participated;
    mapping(address=>uint) won;
    address winner;
    mapping(address=>uint) participantsFunds;
    uint8 numParticipant;
    uint earning;

    constructor(){
        owner=msg.sender;
    }
    
    // For participants to enter the pool
    function enter() public payable {
        require(msg.sender != owner, "Owner cannot Participate");

        uint amount = 0.1 ether + (won[ msg.sender]* 0.01 ether);
        require(msg.value == amount,"Send more than the require amount to participate");
        require(!participated[msg.sender], "You are already participated");

        uint totalAmt = msg.value;
        uint fees = (totalAmt*10)/100;
        uint remainingAmt = totalAmt - fees;

        payable(owner).transfer(fees);
        earning +=fees;
        
        participated[msg.sender]=true;
        participants.push(msg.sender);
        participantsFunds[msg.sender] = remainingAmt;
        numParticipant++;

        if(numParticipant == 5){
            uint8 index = uint8((uint(keccak256(abi.encodePacked(block.number, block.timestamp, participants)))) % 5);
            winner = participants[index];
            payable(winner).transfer(address(this).balance);
            won[winner]++;
            numParticipant=0;
            for(uint8 i=0;i<participants.length;i++){
                participated[participants[i]]=false;
            }
            delete participants;
        }
    }

    // For participants to withdraw from the pool
    function withdraw() public {
        require(participated[msg.sender], "You are not a participant");
        payable(msg.sender).transfer(participantsFunds[msg.sender]);
        participantsFunds[msg.sender]=0;
        participated[msg.sender]=false;

        for(uint8 i=0;i<participants.length;i++){
            if(participants[i] == msg.sender) {
                participants[i] = participants[participants.length-1];
                participants.pop();
                break;
            }
        }
        numParticipant--;
    }

    // To view participants in current pool
    function viewParticipants() public view returns (address[] memory, uint) {
        return (participants,numParticipant);
    }

    // To view winner of last lottery
    function viewPreviousWinner() public view returns (address) {
        require(winner!= address(0),"Lottery has not completed yet");
        return winner;
    }

    // To view the amount earned by Gavin
    function viewEarnings() public view returns (uint256) {
        require(msg.sender == owner, "Owner can only use this function");
        return earning;
    }

    // To view the amount in the pool
    function viewPoolBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
