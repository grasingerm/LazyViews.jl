module MapView

using FastAnonymous
typealias MFunction Union{Function, FastAnonymous.AbstractClosure}

abstract AbstractMapView;

# Lazy view of a function mapped to an array
immutable MapView{T, N} <: AbstractMapView{T, N}
  a::Array{T, N};
  f::MFunction;

  MapView(a::Array{T, N}, f::MFunction) = new(a, f);
end

Base.getindex(mv::MapView, idxs...) = mv.f(mv.a[idxs...]);

# Lazy view of a constant multiplied by each element of an array
type CView{T, N} <: AbstractMapView{T, N}
  a::Array{T, N};
  c::Number;

  CView(a::Array{T, N}, c::Number) = new(a, c);
end

Base.getindex(cv::CView, idxs...) = cv.c * cv.a[idxs...];

# "Weaker" typed, nestable lazy view
immutable LazyView{T, N} <: AbstractMapView{T, N}
  a::Union{Array{T, N}, LazyView{T, N}};
  f::MFunction;

  LazyView(a::Union{Array{T, N}, LazyView{T, N}}, f::MFunction) = new(a, f);
end

Base.getindex(lv::LazyView, idxs...) = lv.f(lv[idxs...]);
import Base.*
*(lv::LazyView, c::Number) = LazyView(lv, @anon x -> c*x);
*(c::Number, lv::LazyView) = lv * c;

# Forward size calls to base array
Base.size(amv::AbstractMapView) = size(amv.a);

import Base.==
function =={T, N}(mv::AbstractMapView{T, N}, a::Array{T, N})
  nrows, ncols = size(mv);
  if (nrows, ncols) != size(a)
    return false;
  else
    for col=1:ncols, row=1:nrows
      if mv[row, col] != a[row, col]; return false; end
    end
    return true;
  end
end
=={T, N}(a::Array{T, N}, mv::AbstractMapView{T, N}) = mv == a;
function =={T, N}(mv1::AbstractMapView{T, N}, mv2::AbstractMapView{T, N})
  nrows, ncols = size(mv1);
  if (nrows, ncols) != size(mv2)
    return false;
  else
    for col=1:ncols, row=1:nrows
      if mv1[row, col] != mv2[row, col]; return false; end
    end
    return true;
  end
end

import Base.!=
!={T, N}(mv::AbstractMapView{T, N}, a::Array{T, N}) = !(mv == a);
!={T, N}(a::Array{T, N}, mv::AbstractMapView{T, N}) = !(mv == a);
!={T, N}(mv1::AbstractMapView{T, N}, mv2::AbstractMapView{T, N}) = !(mv1==mv2);

end # module
