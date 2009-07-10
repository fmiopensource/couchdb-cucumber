Form-based tests for couchdb

Background:
  Given I have a database 'test_db_a'

Scenario: POSTing and HTML document at a database should created a document
  Given I have a form with
        | key  | value           |
        | name | this is my name |
        | age  | 39 |
   When I POST my form to 'test_db_a'
    And I retrieve the document that was just created
   Then the document has 'name' with vlaue 'this is my name'
    And the document has 'age' with value '39'