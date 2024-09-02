// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract HackathonManagement {
    // Owner of the contract
    address public owner;

    // Struct to store hackathon details
    struct Hackathon {
        uint256 id;
        string name;
        uint256 submissionDeadline;
        address[] judges;
        mapping(address => bool) isJudge;
        mapping(address => Project) projects;
        address[] hackers;
    }

    // Struct to store project details
    struct Project {
        string url;
        string feedback;
        bool submitted;
    }

    // Array of hackathons
    Hackathon[] public hackathons;

    // Modifier to check if caller is the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Modifier to check if caller is the admin of the hackathon
    modifier onlyAdmin(uint256 _hackathonId) {
        require(hackathons[_hackathonId].isJudge[msg.sender], "Caller is not an admin of this hackathon");
        _;
    }

    // Modifier to check if caller is a judge of the hackathon
    modifier onlyJudge(uint256 _hackathonId) {
        require(hackathons[_hackathonId].isJudge[msg.sender], "Caller is not a judge of this hackathon");
        _;
    }

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
    }

    // Function to create a new hackathon
    function createHackathon(string memory _name, uint256 _submissionDeadline) public onlyOwner {
        Hackathon storage newHackathon = hackathons.push();
        newHackathon.id = hackathons.length - 1;
        newHackathon.name = _name;
        newHackathon.submissionDeadline = _submissionDeadline;
    }

    // Function to add a judge to a hackathon
    function addJudge(uint256 _hackathonId, address _judge) public onlyAdmin(_hackathonId) {
        Hackathon storage hackathon = hackathons[_hackathonId];
        hackathon.judges.push(_judge);
        hackathon.isJudge[_judge] = true;
    }

    // Function to submit a project
    function submitProject(uint256 _hackathonId, string memory _url) public {
        Hackathon storage hackathon = hackathons[_hackathonId];
        require(block.timestamp <= hackathon.submissionDeadline, "Submission deadline has passed");
        require(!hackathon.projects[msg.sender].submitted, "Project already submitted");

        hackathon.projects[msg.sender] = Project({url: _url, feedback: "", submitted: true});
        hackathon.hackers.push(msg.sender);
    }

    // Function to add feedback to a project
    function addFeedback(uint256 _hackathonId, address _hacker, string memory _feedback)
        public
        onlyJudge(_hackathonId)
    {
        Hackathon storage hackathon = hackathons[_hackathonId];
        require(hackathon.projects[_hacker].submitted, "Project not submitted");

        hackathon.projects[_hacker].feedback = _feedback;
    }

    // Function to view project details (only for judges)
    function viewProject(uint256 _hackathonId, address _hacker)
        public
        view
        onlyJudge(_hackathonId)
        returns (string memory)
    {
        Hackathon storage hackathon = hackathons[_hackathonId];
        require(hackathon.projects[_hacker].submitted, "Project not submitted");

        return hackathon.projects[_hacker].url;
    }

    // Function to view feedback (only for the hacker who submitted the project)
    function viewFeedback(uint256 _hackathonId) public view returns (string memory) {
        Hackathon storage hackathon = hackathons[_hackathonId];
        require(hackathon.projects[msg.sender].submitted, "Project not submitted");

        return hackathon.projects[msg.sender].feedback;
    }

    // Function to get hackathon details
    function getHackathonDetails(uint256 _hackathonId)
        public
        view
        returns (uint256, string memory, uint256, address[] memory)
    {
        Hackathon storage hackathon = hackathons[_hackathonId];
        return (hackathon.id, hackathon.name, hackathon.submissionDeadline, hackathon.judges);
    }

    // Function to get all submitted projects (only for judges)
    function getAllSubmittedProjects(uint256 _hackathonId)
        public
        view
        onlyJudge(_hackathonId)
        returns (address[] memory, string[] memory)
    {
        Hackathon storage hackathon = hackathons[_hackathonId];
        uint256 projectCount = hackathon.hackers.length;

        address[] memory hackerAddresses = new address[](projectCount);
        string[] memory projectUrls = new string[](projectCount);

        for (uint256 i = 0; i < projectCount; i++) {
            address hacker = hackathon.hackers[i];
            hackerAddresses[i] = hacker;
            projectUrls[i] = hackathon.projects[hacker].url;
        }

        return (hackerAddresses, projectUrls);
    }
}
