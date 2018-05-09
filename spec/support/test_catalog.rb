module TestCatalog
  def test_catalog
    @catalog ||= ENV.fetch('TEST_CATALOG'){ File.join(File.dirname(__FILE__), '../../example/facebook-monaleigh') } # ENV is set by dotenv
  end
end
