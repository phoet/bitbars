module Retry
  def with_retry(max_retry_count: 3, retry_timeout: 2)
    retry_count = 0
    yield
  rescue
    raise if retry_count > max_retry_count
    sleep retry_timeout
    retry_count += 1
    retry
  end
end
