RSpec.describe Hn::Rollup::Note do

  it 'creates a note' do
    expect(Hn::Rollup::Note.new({ })).to be_a Hn::Rollup::Note
  end

  it 'creates a displayable note' do
    expect(Hn::Rollup::Note.new({ 'title' => 'test0_title' }).note).to eq({ 'title' => 'test0_title' })
  end

  it 'canonicalizes values' do
    expect(Hn::Rollup::Note.new({ 'title' => 'test0_title' }).canonical).to eq({ 'title' => { 'string' => 'test0_title'} })
  end

  it 'reduces values' do
    expect(Hn::Rollup::Note.new({ 'title' => { 'string' => 'test0_title' } }).reduce)
      .to eq({ 'title' => 'test0_title' })
  end

  it 'leaves values alone' do
    expect(Hn::Rollup::Note.new({ 'title' => { 'string' => 'test0_title' } }).note)
      .to eq({ 'title' => { 'string' => 'test0_title' } })
    expect(Hn::Rollup::Note.new({ 'title' => 'test0_title' }).note)
      .to eq({ 'title' => 'test0_title' })
  end

  it 'aggregates a sibling' do
    note0 = Hn::Rollup::Note.new({ })
    note1 = Hn::Rollup::Note.new({ 'title' => 'note1_title' })
    note2 = Hn::Rollup::Note.new({ 'title' => 'note2_title' })
    expect(note0.aggregate_sibling(note1).note).to eq({ 'title' => 'note1_title' })
    expect(note1.aggregate_sibling(note2).note).to eq({ 'title' => 'note1_title' })
  end

  it 'aggregates a child' do
    parent = Hn::Rollup::Note.new({ 'title' => 'parent_title' })
    child = Hn::Rollup::Note.new({ 'title' => 'child_title' })
    expect(parent.aggregate_child(child).note).to eq({ 'title' => 'parent_title' })
  end

  it 'has children' do
    note_repr = {
      'title' => 'parent_title',
      'children' => [
        { 'title' => 'child_title' }]
    }
    expect(Hn::Rollup::Note.new(note_repr).note).to eq(note_repr)
  end

  it 'has multiple children' do
    note_repr = {
      'title' => 'parent_title',
      'children' => [
        { 'title' => 'child0_title' },
        { 'title' => 'child1_title' }
      ]
    }

    expect(Hn::Rollup::Note.new(note_repr).note).to eq(note_repr)
  end

  it 'has multiple levels of children' do
    note_repr = {
      'title' => 'parent_title',
      'children' => [
        { 'title' => 'child0_title',
          'children' => [
            { 'title' => 'child00_title' },
            { 'title' => 'child01_title' }]},
        { 'title' => 'child1_title',
          'children' => [
            { 'title' => 'child10_title' }]}
      ]}

    expect(Hn::Rollup::Note.new(note_repr).note).to eq(note_repr)
  end


  it 'rolls up children' do
    expect(Hn::Rollup::Note.new({ 'title' => 'parent_title',
                                  'score' => 0,
                                  'children' => [
                                    { 'title' => 'child_title',
                                      'score' => 10 }]}).rollup.note)
      .to eq({ 'title' => 'parent_title', 'score' => 10 })
  end

  it 'rolls up multiple children' do
    expect(Hn::Rollup::Note.new({ 'title' => 'parent_title',
                                  'children' => [
                                    { 'title' => 'child0_title', 'score' => 10 },
                                    { 'title' => 'child1_title', 'score' => 20 }]}).rollup.note)
      .to eq({ 'title' => 'parent_title', 'score' => 30 })
  end

  it 'rolls up multiple levels of children' do
    expect(Hn::Rollup::Note.new({ 'title' => 'parent_title',
                                  'score' => 1,
                                  'children' => [
                                    { 'title' => 'child0_title', 'score' => 10 },
                                    { 'title' => 'child1_title', 'score' => 20,
                                      'children' => [
                                        { 'title' => 'child10_title', 'score' => 100 },
                                        { 'title' => 'child11_title', 'score' => 200 }
                                      ]}
                                  ]}).rollup.note)
      .to eq({ 'title' => 'parent_title', 'score' => 331 })
  end


end
