function ax = set_history_grid(tRec, varargin)
kwargs = parse_function_args(varargin{:});
if isfield(kwargs, 'ax')
    ax = kwargs.ax;
else
    ax = gca;
end
if isfield(kwargs, 'index_io')
    index_io = kwargs.index_io;
else
    index_io = [];
end
if isfield(kwargs, 'dt')
    dt = kwargs.dt;
else
    dt = [];
end


grid on

if isempty(dt)
    t_tick = ax.XTick;
else
    t_tick = 0:dt:tRec(end);
end
if tRec(end) ~= t_tick(end)
    if ~isempty(index_io)
        t_tick = [t_tick, tRec(index_io), tRec(end)];
    else
        t_tick = [t_tick, tRec(end)];
    end
else
    if ~isempty(index_io)
        t_tick = [t_tick, tRec(index_io)];
    else
        t_tick = [t_tick];
    end
end    
t_tick = sort(t_tick);
ax.XTick = t_tick;
end
