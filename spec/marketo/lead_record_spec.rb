require File.expand_path('../spec_helper', File.dirname(__FILE__))

module Grabcad
  module Marketo
    TEST_EMAIL = 'some@email.com'
    TEST_IDNUM    = 93480938
    describe LeadRecord do
      let (:marketo_client) {double}
      it "should store the idnum" do
        lead_record = LeadRecord.new(marketo_client, TEST_EMAIL, TEST_IDNUM)
        lead_record.id.should == TEST_IDNUM
      end

      it "should store the email" do
        LeadRecord.new(marketo_client, TEST_EMAIL, TEST_IDNUM).email.should == TEST_EMAIL
      end

      it "should implement == sensibly" do
        lead_record1 = LeadRecord.new(marketo_client, TEST_EMAIL, TEST_IDNUM)
        lead_record1.set_attribute('favourite color', 'red')
        lead_record1.set_attribute('age', '100')

        lead_record2 = LeadRecord.new(marketo_client, TEST_EMAIL, TEST_IDNUM)
        lead_record2.set_attribute('favourite color', 'red')
        lead_record2.set_attribute('age', '100')

        lead_record1.should == lead_record2
      end

      it "should store when attributes are set" do
        lead_record = LeadRecord.new(marketo_client, TEST_EMAIL, TEST_IDNUM)
        lead_record.set_attribute('favourite color', 'red')
        lead_record.get_attribute('favourite color').should == 'red'
      end

      it "should store when attributes are updated" do
        lead_record = LeadRecord.new(marketo_client, TEST_EMAIL, TEST_IDNUM)
        lead_record.set_attribute('favourite color', 'red')
        lead_record.set_attribute('favourite color', 'green')
        lead_record.get_attribute('favourite color').should == 'green'
      end

      it "should yield all attributes through each_attribute_pair" do
        lead_record = LeadRecord.new(marketo_client, TEST_EMAIL, TEST_IDNUM)
        lead_record.set_attribute('favourite color', 'red')
        lead_record.set_attribute('favourite color', 'green')
        lead_record.set_attribute('age', '99')

        pairs       = []
        lead_record.each_attribute_pair do |attribute_name, attribute_value|
          pairs << [attribute_name, attribute_value]
        end

        pairs.size.should == 3
        pairs.should include(['favourite color', 'green'])
        pairs.should include(['age', '99'])
        pairs.should include(['Email', TEST_EMAIL])
      end

      it "should be instantiable from a savon hash" do
        savon_hash = {
            :email => TEST_EMAIL,
            :foreign_sys_type => nil,
            :lead_attribute_list => {
                :attribute => [
                  { :attr_name => 'Company', :attr_type => 'string', :attr_value => 'Rapleaf'},
                  { :attr_name => 'FirstName', :attr_type => 'string', :attr_value => 'James'},
                  { :attr_name => 'LastName', :attr_type => 'string', :attr_value => 'O\'Brien'}
                ]
            },
            :foreign_sys_person_id => nil,
            :id => TEST_IDNUM
        }

        actual = LeadRecord.from_hash(marketo_client, savon_hash)

        expected = LeadRecord.new(marketo_client, TEST_EMAIL, TEST_IDNUM)
        expected.set_attribute('Company', 'Rapleaf')
        expected.set_attribute('FirstName', 'James')
        expected.set_attribute('LastName', 'O\'Brien')

        actual.should == expected
      end

      it "sync should call client to sync via ID with marketo backend" do
        savon_hash = {
            :email => TEST_EMAIL,
            :foreign_sys_type => nil,
            :lead_attribute_list => {
                :attribute => [
                  { :attr_name => 'Company', :attr_type => 'string', :attr_value => 'Rapleaf'},
                  { :attr_name => 'FirstName', :attr_type => 'string', :attr_value => 'James'},
                  { :attr_name => 'LastName', :attr_type => 'string', :attr_value => 'O\'Brien'}
                ]
            },
            :foreign_sys_person_id => nil,
            :id => TEST_IDNUM
        }
        marketo_client.should_receive(:sync_lead_record_by_id).with(anything).and_return(savon_hash)
        lead_record = LeadRecord.new(marketo_client, TEST_EMAIL, TEST_IDNUM)
        lead_record.sync

      end
    end
  end
end