# ih8-jira
A command-line tool for everyday operations in jira

## Installation
1. clone the repo
2. add the repo directory to your path
3. cd to your repo directory and run "bundle install"
4. set your jira username to the IH8_JIRA_USERNAME environment variable
5. set your jira password to the IH8_JIRA_PASSWORD environment variable
6. mv config.yml.example to config.yml and put data for your jira instance in it

## Usage
### Create a new issues
    $ ih8-jira new --summary "text" --assignee=fred --priority="Low" --description="text"
    DEMO-555
    
### Delete an issue
    $ ih8-jira delete DEMO-555
    
### Set issue fields
    $ ih8-jira set --summary "text" --assignee=fred --priority="Low" --description="text"
    
### Show issue details
    $ ih8-jira show --issue_id=DEMO-555
    
### Show current issues for project
    $ ih8-jira show
    
### Show current issues for project, excluding closed items and backlog items
    $ ih8-jira show --ignore_closed --ignore_backlog
    
### Show project backlog
    $ ih8-jira show --section="Backlog"

### Show all issues that are in "To Do" and assigned to fred
    $ ih8-jira show --section="To Do" --assignee=fred
    
### Move issue from "To Do" to "In Progress"
    $ ih8-jira move DEMO-555 "In Progress"