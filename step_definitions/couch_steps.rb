#
# Givens
#

Given /^I have a new database '([a-z0-9_$()+-\/].+)'$/ do |name|
  create_db(name)
end

Given /^I have 2 new databases: '([a-z0-9_$()+-\/].+)' and '([a-z0-9_$()+-\/].+)'$/ do |dbA, dbB|
  create_db(dbA)
  create_db(dbB)
end

Given "database '$name' has this document" do |name, table|
  id, hash = table_to_doc(table)
  db_put_doc(name, id, hash.to_json)
end

Given "database '$name' has a document with attachment '$filename' of type '$type' and data '$data'" do |name, filename, type, data, table|
  id, hash = table_to_doc(table)
  hash["_attachments"] = { filename => {"type" => type, "data" => data} }
  db_put_doc(name, id, hash.to_json)
end

Given "I have a new document" do |table|
  @docs ||= {}
  id, hash = table_to_doc(table)
  @docs[id] = hash
end

Given "document '$id' has an attachment" do |id, table|

  no_id, hash = table_to_doc(table)

  @docs[id]["_attachments"] = {
    hash["filename"] => {
      "type" => hash["type"],
      "data" => hash["data"]
    }
  } unless @docs.nil?
end

Given "I add document '$id' to '$name'" do |id, name|
  db_put_doc(name, @docs[id]["_id"] ,@docs[id].to_json )
end

#
# When
#
When "I replicate '$source' to '$target'" do |source, target|
  db_replicate(source, target)
end

When "I delete document '$id' from '$name'" do |id, name|
  doc = JSON.parse(db_get_doc(name, id))
  db_delete_doc(name, id, doc["_rev"])
end

#
# Then
#
Then "'$db1' and '$db2' have the same document '$id'" do |db1, db2, id|
  doc1 = db_get_doc(db1, id)
  doc2 = db_get_doc(db1, id)
  doc1.should === doc2
end

Then "the document '$id' is deleted from '$name'" do |id, name|
  lambda{db_get_doc(name, id)}.should raise_error(RestClient::ResourceNotFound)
end

Then "'$name' has the deleted document '$id'" do |name, id|
  docs = JSON.parse(db_get_all_docs_by_sequence(name))
  docs["rows"].select{|row| row["id"] == id}.length.should == 1
end

Then "'$name' has document '$id' with an attachment '$filename' of type '$type'" do |name, id, filename, type|
  attachment = db_get_attachment(name, id, filename)
  attachment.should == "This is a base64 encoded text"
end

Then "I get, with conflicts, document '$id' from '$name'" do |id, name|
  @conflicted ||= {}
  @conflicted["#{name}:#{id}"] = JSON.parse(db_get_doc(name, id, :conflicts => true))
end

Then "conflicted documents should have the same '$key'" do |key|
  @conflicted.each do |doc|
    _rev ||= doc[1][key]
    _rev.should == doc[1][key]
  end
end

Then "conflicted documents should have no $key" do |key|
  key = "_#{key}" if %w(conflict).include?(key)
  @conflicted.each do |doc|
    doc[1][key].should be_nil
  end
end

#
# Helpers
#
def table_to_doc(table)
  hash = {}
  id = ""

  table.hashes.each do |pair|
    if( pair["key"] == "_id" )
      id = pair["value"]
    end
    hash[pair["key"]] = pair["value"]
  end

  return id, hash
end

def create_db(name, delete_first=true)
  if(delete_first)
    begin
      db_delete(name)
    rescue
    end
  end
  db_create(name)
end

