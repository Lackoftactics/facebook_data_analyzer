module TestCatalog
  def test_catalog
    @catalog ||= ENV['TEST_CATALOG'] # ENV is set by dotenv
  end
end