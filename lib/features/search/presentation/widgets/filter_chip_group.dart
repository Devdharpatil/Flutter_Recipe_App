import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'search_theme.dart';

class FilterChipGroup extends StatefulWidget {
  final List<String> options;
  final String? selectedOption;
  final Function(String)? onSelected;
  final Map<String, IconData>? iconMap;
  final bool scrollable;
  final bool showSelectedIndicator;
  final bool multiSelect;
  final List<String>? selectedOptions;
  final Function(List<String>)? onMultiSelected;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;

  const FilterChipGroup({
    super.key,
    required this.options,
    this.selectedOption,
    this.onSelected,
    this.iconMap,
    this.scrollable = true,
    this.showSelectedIndicator = true,
    this.multiSelect = false,
    this.selectedOptions,
    this.onMultiSelected,
    this.spacing = 6.0,
    this.runSpacing = 6.0,
    this.padding,
  }) : assert(
          (!multiSelect && onSelected != null) || (multiSelect && onMultiSelected != null),
          'onSelected must be provided when multiSelect is false, and onMultiSelected must be provided when multiSelect is true',
        );

  @override
  State<FilterChipGroup> createState() => _FilterChipGroupState();
}

class _FilterChipGroupState extends State<FilterChipGroup> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chipWidgets = List.generate(
      widget.options.length,
      (index) => _buildAnimatedChip(
        widget.options[index],
        index,
      ),
    );

    final animatedChips = FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        )),
        child: widget.scrollable
            ? Theme(
                data: Theme.of(context).copyWith(
                  scrollbarTheme: ScrollbarThemeData(
                    thumbColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                    thickness: MaterialStateProperty.all(4.0),
                    radius: const Radius.circular(10.0),
                    thumbVisibility: MaterialStateProperty.all(true),
                    crossAxisMargin: 8.0,
                  ),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: chipWidgets,
                      ),
                    ),
                  ),
                ),
              )
            : Padding(
                padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: widget.spacing,
                  runSpacing: widget.runSpacing,
                  children: chipWidgets,
                ),
              ),
      ),
    );

    return animatedChips;
  }

  Widget _buildAnimatedChip(String option, int index) {
    bool isSelected = widget.multiSelect
        ? widget.selectedOptions?.contains(option) ?? false
        : option == widget.selectedOption;

    return Animate(
      effects: [
        ScaleEffect(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        ),
        FadeEffect(
          begin: 0.6,
          end: 1,
          duration: const Duration(milliseconds: 300),
        ),
      ],
      target: isSelected ? 1 : 0,
      child: Padding(
        padding: EdgeInsets.only(right: widget.scrollable ? 7 : 0),
        child: _buildFilterChip(option, isSelected),
      ),
    );
  }

  Widget _buildFilterChip(String option, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected 
            ? colorScheme.primary
            : colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(SearchThemeRadius.large),
        boxShadow: isSelected ? [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          )
        ] : null,
        border: isSelected 
            ? Border.all(color: colorScheme.primary.withOpacity(0.9), width: 1.5)
            : Border.all(color: colorScheme.outline.withOpacity(0.15), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.multiSelect) {
              final List<String> newSelections = [...(widget.selectedOptions ?? [])];
              if (isSelected) {
                newSelections.remove(option);
              } else {
                newSelections.add(option);
              }
              widget.onMultiSelected!(newSelections);
            } else {
              widget.onSelected!(option);
            }
          },
          splashColor: isSelected 
              ? Colors.white.withOpacity(0.1) 
              : colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SearchThemeRadius.large),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.iconMap?[option] != null) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.2)
                          : colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.iconMap![option],
                      size: 16,
                      color: isSelected 
                          ? colorScheme.onPrimary 
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  option,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? colorScheme.onPrimary 
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isSelected && widget.showSelectedIndicator) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                    .fadeIn(duration: 300.ms)
                    .then(delay: 300.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.1, 1.1),
                      duration: 600.ms,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 