# ih8-jira
A command-line tool for everyday operations in jira

## Installation
1. clone this repo
2. add the repo directory to your path
3. add your jira username to the IH8_JIRA_USERNAME environment variable
4. add your jira password to the IH8_JIRA_PASSWORD environment variable
5. mv config.yml.example to config.yml and put data for your jira instance in it

## Usage
### Create a new issues
    $ ih8-jira new --summary "This is the summary for my new issue"
    DEMO-555
    
### Delete an issue
    $ ih8-jira delete DEMO-555
    
### Set issue fields
    $ ih8-jira set --estimate=5 --assignee=fred
    
### Show issue details
    $ ih8-jira show --issue_id=DEMO-555
    
### Show current sprint for project
    $ ih8-jira show
    
### Show all issues, regardless of sprint assignment
    $ ih8-jira show --sprint=any
    
### Move issue from "To Do" to "In Progress"
    $ ih8-jira move DEMO-555 "In Progress"
    
### Put issue in current sprint
    $ ih8-jira set DEMO-555 --sprint=current
    
### Put issue in the backlog
    $ ih8-jira set DEMO-555 --sprint=none
