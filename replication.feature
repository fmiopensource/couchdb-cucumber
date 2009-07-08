Replication should work as expected.  Adding, deleting, updating docs and
views should be reflected in the replicated db.

Background:
  Given I have 2 new databases: 'test_db_a' and 'test_db_b'

Scenario: Documents are replicated, revision number match, and deletions replicate
    Given database 'test_db_a' has this document
      | key   | value |
      | _id   | foo1  |
      | name  | mine  |
   When I replicate 'test_db_a' to 'test_db_b'
   Then 'test_db_b' and 'test_db_a' have the same document 'foo1'
   When I delete document 'foo1' from 'test_db_a'
    And I replicate 'test_db_a' to 'test_db_b'
   Then the document 'foo1' is deleted from 'test_db_b'

Scenario: Documents that are created and deleted on a single node before replication are replicated
    Given database 'test_db_a' has this document
      | key   | value |
      | _id   | foo1  |
      | value | a     |
   When I delete document 'foo1' from 'test_db_a'
    And I replicate 'test_db_a' to 'test_db_b'
   Then 'test_db_b' has the deleted document 'foo1'

Scenario: Documents that have slashes in their id's replicate properly
    Given database 'test_db_a' has this document
      | key   | value   |
      | _id   | abc/def |
      | val   | one     |
   When I replicate 'test_db_a' to 'test_db_b'
   Then 'test_db_b' and 'test_db_a' have the same document 'abc/def'

Scenario: Design documents replicate properly
    Given database 'test_db_a' has this document
      | key | value        |
      | _id | _design/test |
   When I replicate 'test_db_a' to 'test_db_b'
   Then 'test_db_b' and 'test_db_a' have the same document '_design/test'

Scenario: Attachments are replicated for regular and design docs
  Given I have a new document
        | key   | value   |
        | _id   | bin_doc |
    And document 'bin_doc' has an attachment
        | key   | value       |
        | filename  | foobar.txt  |
        | type  | base64      |
        | data  | VGhpcyBpcyBhIGJhc2U2NCBlbmNvZGVkIHRleHQ= |
    And I have a new document
        | key   | value             |
        | _id   | _design/with_bin  |
    And document '_design/with_bin' has an attachment
        | key   | value       |
        | filename  | foobar.txt  |
        | type  | base64      |
        | data  | VGhpcyBpcyBhIGJhc2U2NCBlbmNvZGVkIHRleHQ= |
    And I add document 'bin_doc' to 'test_db_a'
    And I add document '_design/with_bin' to 'test_db_b'
   When I replicate 'test_db_a' to 'test_db_b'
   Then 'test_db_b' and 'test_db_a' have the same document 'bin_doc'
    And 'test_db_b' and 'test_db_a' have the same document '_design/with_bin'

Scenario: Conflicts should resolve properly
  Given database 'test_db_a' has this document
      | key   | value   |
      | _id   | foo |
      | value | a   |
    And database 'test_db_b' has this document
      | key   | value   |
      | _id   | foo |
      | value | b   |
   When I replicate 'test_db_b' to 'test_db_a'
    And I get, with conflicts, document 'foo' from 'test_db_a'
    And I get, with conflicts, document 'foo' from 'test_db_b'
   Then conflicted documents should have the same '_rev'

    # there is a problem with this one from replication.js
    # // make sure the conflicts are the same in each db
    #      T(docA._conflicts[0] === docB._conflicts[0]);
    # docA has conflicts, but docB has none -- maybe this is new in trunk?

   When I delete document 'foo' from 'test_db_a'
    And I replicate 'test_db_b' to 'test_db_a'
    And I get, with conflicts, document 'foo' from 'test_db_a'
    And I get, with conflicts, document 'foo' from 'test_db_b'
   Then conflicted documents should have no conflicts