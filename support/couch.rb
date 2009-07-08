#
# rest_client wrappers for couch commands
#

module CouchHelpers
  def db_replicate(source, target)
    log_info "db_replication(#{source}, #{target}):"
    log_info RestClient.post("#{COUCH_SERVER}/_replicate",
        "{\"source\":\"#{source}\", \"target\":\"#{target}\"}")
  end

  def db_create(name)
    log_info "db_create(#{name}):"
    log_info RestClient.put("#{COUCH_SERVER}/#{name}/", { })
  end

  def db_delete(name)
    log_info "db_delete(#{name}):"
    log_info RestClient.delete("#{COUCH_SERVER}/#{name}/", { })
  end

  def db_put_doc(name, id, doc)
    log_info "db_put_doc(#{name}, #{id}, #{doc}):"
    log_info RestClient.put("#{COUCH_SERVER}/#{name}/#{id}", doc)
  end

  def db_get_doc(name, id, options={})

    options[:conflicts] ||= false

    log_info "db_get_doc(#{name}, #{id})"
    doc = RestClient.get("#{COUCH_SERVER}/#{name}/#{id}#{"?conflicts=true" if options[:conflicts]}")
    log_info "#{doc}"
    return doc
  end

  def db_get_attachment(name, id, filename)
    log_info "db_get_doc_attachment(#{name}, #{id}, #{filename})"
    attachment = RestClient.get("#{COUCH_SERVER}/#{name}/#{id}/#{filename}")
    log_info "#{attachment}"
    return attachment
  end

  def db_delete_doc(name, id, rev_id)
    log_info "db_delete_doc(#{name}, #{id})"
    log_info RestClient.delete("#{COUCH_SERVER}/#{name}/#{id}?rev=#{rev_id}")
  end

  def db_get_all_docs_by_sequence(name)
    log_info "db_get_all_docs_by_sequence(#{name})"
    docs = RestClient.get("#{COUCH_SERVER}/#{name}/_all_docs_by_seq")
    log_info "#{docs}"
    return docs
  end
end

module LogHelpers
  def log_info(msg)
    LOGGER.info(msg) if LOGGING
  end
end

World(CouchHelpers)
World(LogHelpers)