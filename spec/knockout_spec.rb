require 'spec_helper'

describe KnockoutRails do
  subject { assets }

  it { should serve 'knockout' }
  it { should serve 'knockout/knockout' }
  it { should serve 'knockout/knockout.mapping' }
  it { should serve 'knockout/sugar-1.1.1' }

  it { should serve 'knockout/model' }
  it { should serve 'knockout/observables' }
  it { should serve 'knockout/bindings' }
end
