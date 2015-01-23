require 'spec_helper'

dbname = 'geocode_records_test'

unless ENV['FAST'] == 'true'
  system 'dropdb', '--if-exists', dbname
  system 'createdb', dbname
  system 'psql', dbname, '--command', 'CREATE EXTENSION postgis'
  system 'psql', dbname, '--command', 'CREATE TABLE homes (id serial primary key, the_geom geometry(Geometry,4326), the_geom_webmercator geometry(Geometry,3857), house_number_and_street text, house_number int, unit_number text, city text, state text, postcode text, latitude float, longitude float)'
end

require 'active_record'

ActiveRecord::Base.establish_connection "postgresql://127.0.0.1/#{dbname}"

class Home < ActiveRecord::Base
end

describe GeocodeRecords do
  it 'has a version number' do
    expect(GeocodeRecords::VERSION).not_to be nil
  end

  it "geocodes an AR::Relation" do
    home = Home.create! house_number_and_street: '1038 e deyton st', postcode: '53703'
    GeocodeRecords.new(Home.all).perform
    home.reload
    expect(home.house_number_and_street).to eq('1038 E Dayton St')
  end
end
