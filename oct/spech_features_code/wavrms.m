function rms = wavrms(fname,filter_val)

if (nargin<2)
    filter_val = [];
end

if (~isempty(filter_val))
    b = filter_val(1,:);
    a = filter_val(2,:);
end

sz = wavread(fname, 'size');

if sz(2) ~= 1 && sz(2) ~= 2
    error('File must be either mono or stereo.');
end

[tmp, fs] = wavread(fname, 1);

if (fs ~= 8000)
    error ('Wav file must be 8000 Hz.');
end

% Read not more than 5 minutes at a time.
samples_per_read = 8000*60*5;

num_reads = ceil(sz(1) / samples_per_read);
samples_per_read = floor(sz(1)/num_reads);

total_power = zeros(1, sz(2));
for r = 1:num_reads
    sig = wavread(fname, [(r-1)*samples_per_read+1 r*samples_per_read]);
    if (~isempty(filter_val))
        sig = filter(b,a,sig);
    end
    total_power = total_power + sum(sig.^2);
end

rms = sqrt(total_power/(num_reads * samples_per_read));
