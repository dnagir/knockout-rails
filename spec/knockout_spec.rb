require 'spec_helper'

describe KnockoutRails do
  subject { assets }

  it { should serve 'knockout' }
  it { should serve 'knockout/knockout' }
  it { should serve 'knockout/knockout.mapping' }
  it { should serve 'knockout/sugar-1.1.1' }

  it { should serve 'knockout/model' }
  it { should serve 'knockout/validations' }
  it { should serve 'knockout/validators' }
  it { should serve 'knockout/bindings/animate' }
  it { should serve 'knockout/bindings/autosave' }
  it { should serve 'knockout/bindings/inplace' }
end
